import { createClient, type SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
  "Content-Type": "application/json; charset=utf-8",
};

const REASON_CODES = [
  "good_fit",
  "quick_win",
  "try_something_new",
  "continue_streak",
  "return_gently",
] as const;

type ReasonCode = (typeof REASON_CODES)[number];

type Preference = {
  categories: string[];
  activity_style: "solo" | "group" | "both" | null;
  available_minutes: number | null;
  environment: "indoor" | "outdoor" | "both" | null;
};

type Mission = {
  id: string;
  title: string;
  description: string;
  category: string;
  difficulty: "easy" | "normal" | "challenge";
  estimated_minutes: number;
};

type Activity = {
  mission_id: string;
  completed_at: string;
  mission?: { category: string; difficulty: Mission["difficulty"] } | null;
};

type Recommendation = {
  recommended_mission_id: string;
  reason_code: ReasonCode;
  sidekick_message: string;
  alternative_mission_ids: string[];
};

type JsonRecord = Record<string, unknown>;

const SYSTEM_PROMPT = `You are WE HERO's AI Sidekick. Recommend one small, realistic mission that helps a user build a sustainable habit.

Rules:
- Use only the supplied aggregate preferences, activity summary, and candidate missions.
- Return only the requested JSON object. Never invent a mission ID.
- Do not ask for or infer a user's name, email, location, photo, or other personal data.
- Prefer a good fit for the user's available time. Use quick_win for a very easy, short action; continue_streak when the recent pattern supports continuity; try_something_new for a suitable category change; return_gently for a gentle re-entry after inactivity; otherwise use good_fit.
- sidekick_message must be natural Korean and no more than 80 characters.
- alternative_mission_ids must be different from recommended_mission_id and must come from the candidate list.`;

const OUTPUT_SCHEMA = {
  name: "we_hero_mission_recommendation",
  strict: true,
  schema: {
    type: "object",
    additionalProperties: false,
    properties: {
      recommended_mission_id: { type: "string" },
      reason_code: { type: "string", enum: REASON_CODES },
      sidekick_message: { type: "string" },
      alternative_mission_ids: {
        type: "array",
        items: { type: "string" },
        maxItems: 3,
      },
    },
    required: [
      "recommended_mission_id",
      "reason_code",
      "sidekick_message",
      "alternative_mission_ids",
    ],
  },
};

function jsonResponse(body: JsonRecord, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: corsHeaders,
  });
}

function errorResponse(code: string, message: string, status: number): Response {
  return jsonResponse({ error: { code, message } }, status);
}

function asTrimmedString(value: unknown): string | null {
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function trimKoreanMessage(value: unknown): string {
  const message = asTrimmedString(value) ?? "오늘은 가볍게 하나부터 시작해볼까요?";
  return Array.from(message).slice(0, 80).join("");
}

function startOfUtcDay(): string {
  const now = new Date();
  return new Date(Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate())).toISOString();
}

function fourteenDaysAgo(): string {
  return new Date(Date.now() - 14 * 24 * 60 * 60 * 1000).toISOString();
}

function parseRequestBody(body: unknown): { availableMinutes: number; forceRefresh: boolean } {
  if (!body || typeof body !== "object") {
    throw new RequestError("INVALID_BODY", "요청 본문은 JSON 객체여야 합니다.", 400);
  }

  const input = body as JsonRecord;
  const availableMinutes = input.available_minutes;
  if (
    typeof availableMinutes !== "number" ||
    !Number.isInteger(availableMinutes) ||
    availableMinutes <= 0 ||
    availableMinutes > 24 * 60
  ) {
    throw new RequestError(
      "INVALID_AVAILABLE_MINUTES",
      "available_minutes는 1에서 1440 사이의 정수여야 합니다.",
      400,
    );
  }

  if (input.force_refresh !== undefined && typeof input.force_refresh !== "boolean") {
    throw new RequestError("INVALID_FORCE_REFRESH", "force_refresh는 boolean이어야 합니다.", 400);
  }

  return {
    availableMinutes,
    forceRefresh: input.force_refresh === true,
  };
}

class RequestError extends Error {
  constructor(
    readonly code: string,
    message: string,
    readonly status: number,
  ) {
    super(message);
  }
}

async function getAuthenticatedUser(
  request: Request,
  supabase: SupabaseClient,
): Promise<string> {
  const authorization = request.headers.get("Authorization");
  if (!authorization?.startsWith("Bearer ")) {
    throw new RequestError("UNAUTHORIZED", "Authorization Bearer JWT가 필요합니다.", 401);
  }

  const token = authorization.slice("Bearer ".length).trim();
  if (!token) {
    throw new RequestError("UNAUTHORIZED", "유효한 JWT가 필요합니다.", 401);
  }

  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data.user) {
    throw new RequestError("UNAUTHORIZED", "JWT 검증에 실패했습니다.", 401);
  }
  console.log(`[recommend-missions] authenticated user=${data.user.id}`);
  return data.user.id;
}

function preferenceFromRow(row: JsonRecord | null, requestedMinutes: number): Preference {
  const categories = Array.isArray(row?.categories)
    ? row.categories.filter((value): value is string => typeof value === "string")
    : [];
  const activityStyle = row?.activity_style;
  const environment = row?.environment;
  return {
    categories,
    activity_style:
      activityStyle === "solo" || activityStyle === "group" || activityStyle === "both"
        ? activityStyle
        : "both",
    available_minutes:
      typeof row?.available_minutes === "number" ? row.available_minutes : requestedMinutes,
    environment:
      environment === "indoor" || environment === "outdoor" || environment === "both"
        ? environment
        : "both",
  };
}

function uniqueStrings(values: string[]): string[] {
  return [...new Set(values)];
}

function fallbackRecommendation(
  candidates: Mission[],
  preferences: Preference,
  activities: Activity[],
  todayCompletedMissionIds: Set<string>,
): Recommendation {
  const recentCategories = activities
    .filter((activity) => activity.mission?.category)
    .sort((a, b) => Date.parse(b.completed_at) - Date.parse(a.completed_at))
    .map((activity) => activity.mission?.category as string);
  const lastCategory = recentCategories[0];
  const sameCategoryStreak = recentCategories.length >= 3 &&
    recentCategories.slice(0, 3).every((category) => category === lastCategory);
  const completedCategoryCounts = new Map<string, number>();
  for (const category of recentCategories) {
    completedCategoryCounts.set(category, (completedCategoryCounts.get(category) ?? 0) + 1);
  }

  const ranked = candidates
    .filter((mission) => !todayCompletedMissionIds.has(mission.id))
    .map((mission) => {
      const preferenceMatch = preferences.categories.length === 0
        ? 1
        : preferences.categories.includes(mission.category)
          ? 1
          : 0;
      const timeFit = mission.estimated_minutes <= (preferences.available_minutes ?? Infinity) ? 1 : 0;
      const categoryVariety = lastCategory && mission.category === lastCategory ? 0 : 1;
      const difficultyFit = mission.difficulty === "challenge" && recentCategories.length < 2 ? 0 : 1;
      const streakPenalty = sameCategoryStreak && mission.category === lastCategory ? -2 : 0;
      const score = preferenceMatch * 4 + timeFit * 3 + categoryVariety * 2 + difficultyFit + streakPenalty;
      return { mission, score, completedIn14Days: completedCategoryCounts.get(mission.category) ?? 0 };
    })
    .sort((a, b) => b.score - a.score || a.mission.estimated_minutes - b.mission.estimated_minutes || a.mission.id.localeCompare(b.mission.id));

  const selected = ranked[0]?.mission ?? candidates[0];
  if (!selected) {
    throw new RequestError("NO_CANDIDATES", "추천 가능한 미션이 없습니다.", 404);
  }

  const alternatives = ranked
    .map((entry) => entry.mission.id)
    .filter((id) => id !== selected.id)
    .slice(0, 3);
  const selectedRank = ranked[0];
  let reasonCode: ReasonCode = "good_fit";
  if (recentCategories.length === 0) reasonCode = "return_gently";
  else if (selected.estimated_minutes <= 10) reasonCode = "quick_win";
  else if (sameCategoryStreak && selected.category !== lastCategory) reasonCode = "try_something_new";
  else if (selectedRank?.completedIn14Days > 0) reasonCode = "continue_streak";

  return {
    recommended_mission_id: selected.id,
    reason_code: reasonCode,
    sidekick_message: trimKoreanMessage(
      reasonCode === "quick_win"
        ? "부담 없이 오늘의 작은 성공부터 시작해볼까요?"
        : reasonCode === "try_something_new"
          ? "새로운 카테고리로 기분 좋은 변화를 만들어볼까요?"
          : reasonCode === "return_gently"
            ? "괜찮아요. 오늘은 가볍게 하나부터 다시 시작해봐요."
            : reasonCode === "continue_streak"
              ? "좋은 흐름이에요. 오늘도 이어서 한 걸음 가볼까요?"
              : "지금 할 수 있는 미션으로 오늘의 히어로가 되어봐요!",
    ),
    alternative_mission_ids: alternatives,
  };
}

async function readOpenAiRecommendation(
  candidates: Mission[],
  preferences: Preference,
  activities: Activity[],
): Promise<Recommendation> {
  const apiKey = Deno.env.get("OPENAI_API_KEY");
  const model = Deno.env.get("OPENAI_MODEL");
  if (!apiKey || !model) throw new Error("OpenAI secrets are not configured");

  const aggregate = {
    preferences,
    activity_summary: {
      period_days: 14,
      completion_count: activities.length,
      recent_categories: activities
        .filter((activity) => activity.mission?.category)
        .slice(0, 6)
        .map((activity) => activity.mission?.category),
      recent_difficulties: activities
        .filter((activity) => activity.mission?.difficulty)
        .slice(0, 6)
        .map((activity) => activity.mission?.difficulty),
    },
    candidates: candidates.map(({ id, title, description, category, difficulty, estimated_minutes }) => ({
      id,
      title,
      description,
      category,
      difficulty,
      estimated_minutes,
    })),
  };

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model,
      temperature: 0.2,
      messages: [
        { role: "system", content: SYSTEM_PROMPT },
        { role: "user", content: JSON.stringify(aggregate) },
      ],
      response_format: { type: "json_schema", json_schema: OUTPUT_SCHEMA },
    }),
  });

  if (!response.ok) {
    throw new Error(`OpenAI request failed with status ${response.status}`);
  }
  const payload = await response.json() as JsonRecord;
  const content = (payload.choices as JsonRecord[] | undefined)?.[0]?.message;
  const rawContent = content && typeof content === "object" ? (content as JsonRecord).content : null;
  if (typeof rawContent !== "string") throw new Error("OpenAI response did not contain JSON content");

  const parsed = JSON.parse(rawContent) as JsonRecord;
  const candidateIds = new Set(candidates.map((mission) => mission.id));
  const recommendedId = asTrimmedString(parsed.recommended_mission_id);
  const reasonCode = parsed.reason_code;
  const alternatives = Array.isArray(parsed.alternative_mission_ids)
    ? parsed.alternative_mission_ids.filter((id): id is string => typeof id === "string")
    : [];

  if (!recommendedId || !candidateIds.has(recommendedId) || !REASON_CODES.includes(reasonCode as ReasonCode)) {
    throw new Error("OpenAI recommendation failed candidate or reason validation");
  }

  return {
    recommended_mission_id: recommendedId,
    reason_code: reasonCode as ReasonCode,
    sidekick_message: trimKoreanMessage(parsed.sidekick_message),
    alternative_mission_ids: uniqueStrings(
      alternatives.filter((id) => candidateIds.has(id) && id !== recommendedId),
    ).slice(0, 3),
  };
}

async function saveRecommendation(
  supabase: SupabaseClient,
  userId: string,
  recommendation: Recommendation,
): Promise<void> {
  const { error } = await supabase.from("sidekick_recommendations").insert({
    user_id: userId,
    mission_ids: [
      recommendation.recommended_mission_id,
      ...recommendation.alternative_mission_ids,
    ],
    message: recommendation.sidekick_message,
  });
  if (error) throw new Error(`Failed to save recommendation: ${error.message}`);
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (request.method !== "POST") return errorResponse("METHOD_NOT_ALLOWED", "POST 요청만 허용됩니다.", 405);

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
    const authHeader = request.headers.get("Authorization");
    if (!supabaseUrl || !anonKey || !authHeader) {
      return errorResponse("SERVER_MISCONFIGURED", "Supabase 인증 환경이 설정되지 않았습니다.", 500);
    }

    // Forward the caller JWT so every PostgREST query runs as that user and
    // is evaluated by the database RLS policies.
    const supabase = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
      auth: { autoRefreshToken: false, persistSession: false },
    });
    const userId = await getAuthenticatedUser(request, supabase);
    const input = parseRequestBody(await request.json());
    console.log(`[recommend-missions] request parsed user=${userId} availableMinutes=${input.availableMinutes} forceRefresh=${input.forceRefresh}`);

    const { data: preferenceRow, error: preferenceError } = await supabase
      .from("user_preferences")
      .select("categories, activity_style, available_minutes, environment")
      .eq("user_id", userId)
      .maybeSingle();
    if (preferenceError) {
      console.error(`[recommend-missions] db preferences failed code=${preferenceError.code} message=${preferenceError.message}`);
      throw new Error(`Failed to load preferences: ${preferenceError.message}`);
    }
    const preferences = preferenceFromRow(preferenceRow as JsonRecord | null, input.availableMinutes);
    console.log(`[recommend-missions] preferences loaded user=${userId} present=${preferenceRow != null} categories=${preferences.categories.length} minutes=${preferences.available_minutes} style=${preferences.activity_style ?? "both"} environment=${preferences.environment ?? "both"}`);

    const { data: activityRows, error: activityError } = await supabase
      .from("activities")
      .select("mission_id, completed_at, missions(category, difficulty)")
      .eq("user_id", userId)
      .gte("completed_at", fourteenDaysAgo())
      .order("completed_at", { ascending: false });
    if (activityError) {
      console.error(`[recommend-missions] db activities failed code=${activityError.code} message=${activityError.message}`);
      throw new Error(`Failed to load activity summary: ${activityError.message}`);
    }
    const activities = (activityRows ?? []) as Activity[];
    console.log(`[recommend-missions] activities loaded count=${activities.length}`);

    const todayStart = startOfUtcDay();
    const todayCompletedMissionIds = new Set(
      activities
        .filter((activity) => activity.completed_at >= todayStart)
        .map((activity) => activity.mission_id),
    );

    if (!input.forceRefresh) {
      const { data: cachedRow, error: cacheError } = await supabase
        .from("sidekick_recommendations")
        .select("mission_ids, message, created_at")
        .eq("user_id", userId)
        .gte("created_at", todayStart)
        .order("created_at", { ascending: false })
        .limit(1)
        .maybeSingle();
      if (cacheError) {
        console.error(`[recommend-missions] db cache failed code=${cacheError.code} message=${cacheError.message}`);
        throw new Error(`Failed to load recommendation cache: ${cacheError.message}`);
      }
      const cachedIds = Array.isArray(cachedRow?.mission_ids)
        ? cachedRow.mission_ids.filter((id): id is string => typeof id === "string")
        : [];
      if (cachedIds[0]) {
        console.log(`[recommend-missions] cache hit user=${userId} alternatives=${cachedIds.length - 1}`);
        return jsonResponse({
          recommended_mission_id: cachedIds[0],
          reason_code: "good_fit",
          sidekick_message: trimKoreanMessage(cachedRow?.message),
          alternative_mission_ids: cachedIds.slice(1, 4),
          source: "cache",
          cached_at: cachedRow?.created_at,
        });
      }
    }

    const { data: missionRows, error: missionError } = await supabase
      .from("missions")
      .select("id, title, description, category, difficulty, estimated_minutes")
      .eq("active", true)
      .lte("estimated_minutes", input.availableMinutes)
      .order("estimated_minutes", { ascending: true })
      .limit(50);
    if (missionError) {
      console.error(`[recommend-missions] db missions failed code=${missionError.code} message=${missionError.message}`);
      throw new Error(`Failed to load missions: ${missionError.message}`);
    }

    const candidates = (missionRows ?? [])
      .filter((mission) => !todayCompletedMissionIds.has(mission.id))
      .slice(0, 12) as Mission[];
    if (candidates.length === 0) {
      throw new RequestError("NO_CANDIDATES", "조건에 맞는 미션이 없습니다.", 404);
    }
    console.log(`[recommend-missions] candidates loaded count=${candidates.length}`);

    let recommendation: Recommendation;
    let source: "ai" | "fallback";
    try {
      recommendation = await readOpenAiRecommendation(candidates, preferences, activities);
      source = "ai";
      console.log(`[recommend-missions] openai recommendation succeeded mission=${recommendation.recommended_mission_id}`);
    } catch (openAiError) {
      console.warn(`[recommend-missions] openai failed; using fallback type=${openAiError instanceof Error ? openAiError.name : typeof openAiError} message=${openAiError instanceof Error ? openAiError.message : String(openAiError)}`);
      recommendation = fallbackRecommendation(candidates, preferences, activities, todayCompletedMissionIds);
      source = "fallback";
      console.log(`[recommend-missions] fallback recommendation succeeded mission=${recommendation.recommended_mission_id}`);
    }

    try {
      await saveRecommendation(supabase, userId, recommendation);
      console.log(`[recommend-missions] recommendation saved user=${userId}`);
    } catch (saveError) {
      console.error(`[recommend-missions] db recommendation save failed type=${saveError instanceof Error ? saveError.name : typeof saveError} message=${saveError instanceof Error ? saveError.message : String(saveError)}`);
      console.warn('[recommend-missions] returning generated recommendation despite save failure');
    }
    console.log(`[recommend-missions] response source=${source} mission=${recommendation.recommended_mission_id}`);
    return jsonResponse({ ...recommendation, source });
  } catch (error) {
    if (error instanceof RequestError) return errorResponse(error.code, error.message, error.status);
    console.error(`[recommend-missions] failed type=${error instanceof Error ? error.name : typeof error} message=${error instanceof Error ? error.message : String(error)}`);
    return errorResponse("INTERNAL_ERROR", "추천 미션을 처리하지 못했습니다.", 500);
  }
});
