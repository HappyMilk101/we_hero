-- Prototype missions. The current schema has no unique title constraint, so
-- the NOT EXISTS guard makes this seed safe to run repeatedly.
insert into public.missions (
  title, description, category, difficulty, estimated_minutes,
  base_coin_reward, base_xp_reward, verification_type, active
)
select v.title, v.description, v.category, v.difficulty, v.estimated_minutes,
       v.base_coin_reward, v.base_xp_reward, 'photo', true
from (values
  ('10분 플로깅', '안전한 경로를 걸으며 눈에 보이는 쓰레기를 줍고 분리해요.', 'environment', 'easy', 10, 10, 10),
  ('텀블러 사용하기', '오늘 한 번 일회용 컵 대신 개인 컵을 사용해요.', 'environment', 'easy', 5, 5, 5),
  ('분리배출 점검하기', '집에 있는 재활용품 5개를 재질에 맞게 다시 분류해요.', 'environment', 'normal', 15, 18, 20),
  ('일회용품 하나 줄이기', '오늘 사용할 물건 중 일회용품 하나를 다회용품으로 바꿔요.', 'environment', 'normal', 20, 20, 25),
  ('동네 쓰레기 10개 줍기', '장갑과 집게를 사용해 가까운 공공장소의 쓰레기 10개를 주워요.', 'environment', 'challenge', 40, 30, 35),
  ('나에게 따뜻한 차 준비하기', '잠시 쉬며 물이나 차를 준비하고 천천히 마셔요.', 'care', 'easy', 5, 5, 5),
  ('10분 스트레칭하기', '무리하지 않는 범위에서 전신 스트레칭으로 몸을 풀어요.', 'care', 'easy', 10, 10, 10),
  ('휴식 공간 정돈하기', '내가 쉬는 공간을 15분 동안 정리하고 편하게 만들어요.', 'care', 'normal', 15, 18, 20),
  ('오늘의 기분 기록하기', '오늘의 기분과 고마웠던 일 한 가지를 짧게 적어요.', 'care', 'normal', 20, 20, 25),
  ('나를 위한 한 시간 만들기', '알림을 잠시 끄고 좋아하는 안전한 활동에 한 시간을 써요.', 'care', 'challenge', 60, 30, 40),
  ('물건 3개 기부 준비하기', '상태가 좋은 물건 3개를 골라 기부 가능한 상태로 정리해요.', 'sharing', 'easy', 15, 12, 12),
  ('지역 나눔함 위치 확인하기', '가까운 공식 나눔함이나 기부처의 위치와 운영시간을 찾아봐요.', 'sharing', 'easy', 10, 10, 10),
  ('필요한 물건 나눔 글 살펴보기', '신뢰할 수 있는 지역 플랫폼에서 나눔이 필요한 물건을 확인해요.', 'sharing', 'normal', 20, 18, 20),
  ('사용하지 않는 책 5권 정리', '다시 읽지 않을 책을 골라 공식 기부처에 나눌 준비를 해요.', 'sharing', 'normal', 30, 22, 28),
  ('기부 물품 포장하기', '기부하기로 한 물품을 깨끗이 확인하고 안전하게 포장해요.', 'sharing', 'challenge', 45, 30, 35),
  ('새로운 주제 5분 읽기', '관심 있는 공익·환경 주제의 짧은 글을 읽고 한 줄로 정리해요.', 'education', 'easy', 5, 5, 5),
  ('재활용 표시 알아보기', '자주 보는 포장재의 재활용 표시 3가지를 찾아 의미를 익혀요.', 'education', 'easy', 10, 10, 10),
  ('지역 공공서비스 찾아보기', '생활에 도움이 되는 공공서비스 하나를 찾아 이용 방법을 적어요.', 'education', 'normal', 20, 18, 22),
  ('환경 발자국 줄이는 방법 조사', '일상에서 실천할 수 있는 방법 3가지를 조사해 기록해요.', 'education', 'normal', 30, 22, 28),
  ('온라인 무료 강의 한 편 듣기', '공익이나 생활 기술에 관한 무료 강의를 한 편 끝까지 들어요.', 'education', 'challenge', 60, 30, 40),
  ('반려동물 물그릇 확인하기', '반려동물의 물그릇을 깨끗이 씻고 신선한 물을 채워요.', 'animal', 'easy', 5, 5, 5),
  ('반려동물 배변 흔적 정리하기', '공용 공간의 반려동물 배변 흔적을 책임 있게 정리해요.', 'animal', 'easy', 10, 10, 10),
  ('보호소 필요물품 확인하기', '공식 보호소의 공개된 필요물품 목록을 확인하고 기록해요.', 'animal', 'normal', 15, 18, 20),
  ('동물 복지 정보 읽기', '신뢰할 수 있는 기관의 동물 복지 안내를 읽고 한 가지를 실천해요.', 'animal', 'normal', 25, 20, 25),
  ('반려동물 산책과 주변 정리', '반려동물과 안전하게 산책하고 사용한 배변 봉투를 처리해요.', 'animal', 'challenge', 45, 28, 35),
  ('공공장소 주변 5분 정리', '내가 이용한 공공장소 주변의 작은 쓰레기를 주워 정리해요.', 'community', 'easy', 5, 5, 5),
  ('동네 게시판 정보 확인하기', '공식 동네 게시판에서 유용한 지역 소식 하나를 확인해요.', 'community', 'easy', 10, 10, 10),
  ('지역 봉사 프로그램 찾아보기', '공식 기관의 지역 봉사 프로그램 하나를 찾아 참여 조건을 확인해요.', 'community', 'normal', 20, 18, 22),
  ('이웃을 위한 정보 공유하기', '공식 출처의 유용한 지역 정보를 온라인으로 공유해요.', 'community', 'normal', 15, 18, 20),
  ('지역사회 봉사활동 참여하기', '허가된 범위에서 공공장소를 30분 정리하고 쓰레기를 분류해요.', 'community', 'challenge', 30, 28, 35)
) as v(title, description, category, difficulty, estimated_minutes, base_coin_reward, base_xp_reward)
where not exists (select 1 from public.missions m where m.title = v.title);
