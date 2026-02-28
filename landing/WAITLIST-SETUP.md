# Waitlist Form Setup — Google Sheets + Apps Script

## Шаг 1: Создай Google Sheet

1. Зайди на https://sheets.google.com под аккаунтом **info@anticifi.com**
2. Создай новую таблицу, назови **"AnticiFi Waitlist"**
3. В ячейке **A1** напиши `email`, в **B1** — `date`

## Шаг 2: Создай Apps Script

1. В таблице: **Extensions → Apps Script**
2. Удали весь код и вставь:

```javascript
function doPost(e) {
  var sheet = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
  var email = e.parameter.email;

  if (!email) {
    return ContentService
      .createTextOutput(JSON.stringify({ status: 'error', message: 'No email' }))
      .setMimeType(ContentService.MimeType.JSON);
  }

  // Check for duplicates
  var emails = sheet.getRange('A:A').getValues().flat();
  if (emails.includes(email)) {
    return ContentService
      .createTextOutput(JSON.stringify({ status: 'duplicate', message: 'Already registered' }))
      .setMimeType(ContentService.MimeType.JSON);
  }

  // Append new row
  sheet.appendRow([email, new Date().toISOString()]);

  // Optional: send notification to yourself
  MailApp.sendEmail({
    to: 'info@anticifi.com',
    subject: 'New AnticiFi Waitlist Signup',
    body: 'New signup: ' + email + '\nDate: ' + new Date().toISOString()
  });

  return ContentService
    .createTextOutput(JSON.stringify({ status: 'ok' }))
    .setMimeType(ContentService.MimeType.JSON);
}
```

3. Сохрани (Ctrl+S)

## Шаг 3: Deploy

1. Нажми **Deploy → New deployment**
2. Тип: **Web app**
3. Настройки:
   - Description: `AnticiFi Waitlist`
   - Execute as: **Me (info@anticifi.com)**
   - Who has access: **Anyone**
4. Нажми **Deploy**
5. Разреши доступ (Google покажет предупреждение — нажми "Advanced" → "Go to AnticiFi Waitlist (unsafe)")
6. Скопируй **Web app URL** — он будет вида:
   ```
   https://script.google.com/macros/s/AKfycb.../exec
   ```

## Шаг 4: Вставь URL в лендинг

В файле `landing/index.html` найди строку:

```javascript
const APPS_SCRIPT_URL = 'YOUR_APPS_SCRIPT_URL_HERE';
```

Замени `YOUR_APPS_SCRIPT_URL_HERE` на скопированный URL.

## Готово!

Теперь при submit формы:
- Email записывается в Google Sheet
- Ты получаешь email-уведомление на info@anticifi.com
- Пользователь видит success-сообщение

## Тестирование

1. Открой `landing/index.html` в браузере
2. Введи тестовый email и нажми "Join the Waitlist"
3. Проверь Google Sheet — новая строка должна появиться
4. Проверь почту info@anticifi.com — должно прийти уведомление
