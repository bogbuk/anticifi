#!/bin/bash
# OCR Receipt Test Script
# Tests receipt scanning for all currencies and generates a report

API_URL="https://api.anticifi.com/api"
RECEIPT_DIR="$(dirname "$0")"
REPORT_FILE="$RECEIPT_DIR/test-report.md"

# Login
echo "Logging in..."
TOKEN=$(curl -s "$API_URL/auth/login" \
  -H 'Content-Type: application/json' \
  -d '{"email":"bogdan+pro@anticifi.com","password":"Test1234"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin).get('accessToken',''))")

if [ -z "$TOKEN" ]; then
  echo "ERROR: Failed to login"
  exit 1
fi
echo "Login OK"

# Init report
cat > "$REPORT_FILE" << 'HEADER'
# OCR Receipt Test Report

| Currency | File | Detected Currency | Amount | Merchant | Date | Confidence | Status |
|----------|------|-------------------|--------|----------|------|------------|--------|
HEADER

TOTAL=0
SUCCESS=0
CURRENCY_OK=0
AMOUNT_OK=0

for CURRENCY_DIR in "$RECEIPT_DIR"/*/; do
  CURRENCY=$(basename "$CURRENCY_DIR")
  # Skip non-directory entries
  [ ! -d "$CURRENCY_DIR" ] && continue

  for IMG in "$CURRENCY_DIR"*.jpg "$CURRENCY_DIR"*.jpeg "$CURRENCY_DIR"*.png "$CURRENCY_DIR"*.webp "$CURRENCY_DIR"*.JPG; do
    [ ! -f "$IMG" ] && continue
    FILENAME=$(basename "$IMG")
    TOTAL=$((TOTAL + 1))

    echo "[$CURRENCY] Testing $FILENAME..."

    RESPONSE=$(curl -s -X POST "$API_URL/receipts/scan" \
      -H "Authorization: Bearer $TOKEN" \
      -F "image=@$IMG" \
      --max-time 120 2>&1)

    if echo "$RESPONSE" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
      # Parse response
      DETECTED=$(echo "$RESPONSE" | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = d.get('receipt', d)
p = r.get('parsedData', {}) or {}
print(p.get('currency', 'N/A'))
")
      AMOUNT=$(echo "$RESPONSE" | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = d.get('receipt', d)
p = r.get('parsedData', {}) or {}
a = p.get('amount')
print(f'{a:.2f}' if a else 'N/A')
")
      MERCHANT=$(echo "$RESPONSE" | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = d.get('receipt', d)
p = r.get('parsedData', {}) or {}
m = p.get('merchant', 'N/A') or 'N/A'
print(m[:30])
")
      DATE=$(echo "$RESPONSE" | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = d.get('receipt', d)
p = r.get('parsedData', {}) or {}
print(p.get('date', 'N/A') or 'N/A')
")
      CONF=$(echo "$RESPONSE" | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = d.get('receipt', d)
c = r.get('confidence', 0)
print(f'{float(c):.0f}%')
")
      STATUS=$(echo "$RESPONSE" | python3 -c "
import sys, json
d = json.load(sys.stdin)
r = d.get('receipt', d)
print(r.get('status', 'unknown'))
")

      SUCCESS=$((SUCCESS + 1))

      # Check currency match
      CURR_MATCH="no"
      if [ "$DETECTED" = "$CURRENCY" ]; then
        CURRENCY_OK=$((CURRENCY_OK + 1))
        CURR_MATCH="yes"
      fi

      # Check if amount was detected
      if [ "$AMOUNT" != "N/A" ]; then
        AMOUNT_OK=$((AMOUNT_OK + 1))
      fi

      # Currency match indicator
      if [ "$CURR_MATCH" = "yes" ]; then
        CURR_DISPLAY="$DETECTED ✓"
      else
        CURR_DISPLAY="$DETECTED ✗"
      fi

      echo "| $CURRENCY | $FILENAME | $CURR_DISPLAY | $AMOUNT | $MERCHANT | $DATE | $CONF | $STATUS |" >> "$REPORT_FILE"
      echo "  → Currency: $DETECTED ($CURR_MATCH) | Amount: $AMOUNT | Confidence: $CONF"
    else
      echo "| $CURRENCY | $FILENAME | ERROR | - | - | - | - | failed |" >> "$REPORT_FILE"
      echo "  → ERROR: Invalid response"
    fi
  done
done

# Summary
cat >> "$REPORT_FILE" << EOF

## Summary

- **Total receipts tested:** $TOTAL
- **Successfully scanned:** $SUCCESS / $TOTAL
- **Currency correctly detected:** $CURRENCY_OK / $SUCCESS
- **Amount detected:** $AMOUNT_OK / $SUCCESS
- **Currency detection rate:** $(( CURRENCY_OK * 100 / (SUCCESS > 0 ? SUCCESS : 1) ))%
- **Amount detection rate:** $(( AMOUNT_OK * 100 / (SUCCESS > 0 ? SUCCESS : 1) ))%
EOF

echo ""
echo "========================================="
echo "  TEST COMPLETE"
echo "  Total: $TOTAL | Scanned: $SUCCESS"
echo "  Currency OK: $CURRENCY_OK | Amount OK: $AMOUNT_OK"
echo "========================================="
echo "Report: $REPORT_FILE"
