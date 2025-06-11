#!/bin/sh
set -x  # 디버깅용


TERM_LIST="T1 T2"
OUTPUT_FILE="/usr/share/nginx/html/index.html"

mkdir -p "$(dirname "$OUTPUT_FILE")"

# 백업 디렉토리 지정
BACKUP_DIR="/usr/share/nginx/html/backups"
mkdir -p "$BACKUP_DIR"

# 기존 index.html 백업
if [ -f "$OUTPUT_FILE" ]; then
  cp "$OUTPUT_FILE" "$BACKUP_DIR/index_$(date +%Y%m%d_%H%M%S).html"
fi

NOW=$(date "+%Y-%m-%d %H:%M:%S")
echo "updated at $(date)" >> /usr/share/nginx/html/cron.log
# HTML 헤더 및 갱신 정보
cat <<EOF > "$OUTPUT_FILE"
<html>
<head>
  <meta charset="UTF-8">
  <meta http-equiv="refresh" content="60">
  <title>입국장 혼잡도</title>
  <style>
    body { font-family: sans-serif; }
    p { margin: 0.5em 0; }
    .notice { font-size: 1em; color: gray; }
  </style>
</head>
<body>
  <h1>입국장 혼잡도 현황</h1>
  <p class="notice">⏱️ 이 페이지는 <strong>1분마다 자동 새로고침</strong>됩니다.</p>
  <p class="notice">📅 마지막 업데이트: <strong>${NOW}</strong></p>
  <table border="1" cellpadding="5" cellspacing="0">
  <p class="notice">
  📁 <a href="/backups/">이전 백업 목록 보기</a>
</p>

    <tr>
      <th>터미널</th><th>입국장</th><th>편명</th><th>도착예정</th>
      <th>도착실제</th><th>내국인</th><th>외국인</th>
    </tr>
EOF

# 각 터미널에 대해 API 요청 → 데이터 파싱
for T in $TERM_LIST; do
    curl -s "http://apis.data.go.kr/B551177/StatusOfArrivals/getArrivalsCongestion?serviceKey=${SERVICE_KEY}&type=xml&numOfRows=100&pageNo=1&terno=${T}" > /tmp/res.xml

    COUNT=$(xmllint --xpath 'count(//item)' /tmp/res.xml)
    i=1
    while [ $i -le $COUNT ]; do
        ENTRYGATE=$(xmllint --xpath "string(//item[$i]/entrygate)" /tmp/res.xml)
        FLIGHTID=$(xmllint --xpath "string(//item[$i]/flightid)" /tmp/res.xml)
        SCHEDULE=$(xmllint --xpath "string(//item[$i]/scheduletime)" /tmp/res.xml)
        ESTIMATE=$(xmllint --xpath "string(//item[$i]/estimatedtime)" /tmp/res.xml)
        KOREAN=$(xmllint --xpath "string(//item[$i]/korean)" /tmp/res.xml)
        FOREIGNER=$(xmllint --xpath "string(//item[$i]/foreigner)" /tmp/res.xml)

        echo "    <tr><td>$T</td><td>$ENTRYGATE</td><td>$FLIGHTID</td><td>$SCHEDULE</td><td>$ESTIMATE</td><td>$KOREAN</td><td>$FOREIGNER</td></tr>" >> "$OUTPUT_FILE"
        i=$((i + 1))
    done
done

# HTML 닫기
cat <<EOF >> "$OUTPUT_FILE"
  </table>
  <p class="notice">
    📁 <a href="/backups/">이전 백업 목록 보기</a>
  </p>
</body>
</html>
EOF

# ✅ 이 시점 이후에 백업 수행 (완성된 파일을 저장)
BACKUP_DIR="/usr/share/nginx/html/backups"
mkdir -p "$BACKUP_DIR"
cp "$OUTPUT_FILE" "$BACKUP_DIR/index_$(date +%Y%m%d_%H%M%S).html"

