insert into public.missions (title, description, category, difficulty, estimated_minutes, base_coin_reward, base_xp_reward)
values
('플로깅 10분','동네를 산책하며 쓰레기를 주워보세요.','environment','easy',10,10,10),
('텀블러 사용하기','일회용 컵 대신 나의 컵을 사용해요.','environment','easy',5,5,5),
('물건 3개 기부 준비하기','사용하지 않는 물건을 골라 나눔을 준비해요.','sharing','easy',20,15,10),
('지역사회 봉사활동 참여하기','지역을 더 따뜻하게 만드는 활동에 참여해요.','community','challenge',120,30,40)
on conflict do nothing;
