FROM alpine

# 필요한 패키지 설치
RUN apk add --no-cache openssh autossh

# 스크립트 파일 복사
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh

# SSH 키는 이미지에 굽지 않는다. docker-compose.yml 에서 /ssh-src 로
# read-only 마운트하고 entrypoint 가 /root/.ssh 로 복사한다.

# 컨테이너 시작 시 실행할 명령어
ENTRYPOINT ["/root/entrypoint.sh"]
