# jgd-forms-layout: Common Login Form Example
# ตัวอย่างระบบล็อกอิน (Login Form) ด้วย jgd-forms-layout

This project demonstrates how to build a responsive, grid-based login interface programmatically using the `jgd-forms-layout` component.

โครงการนี้สาธิตวิธีการสร้างหน้าจอเข้าสู่ระบบ (Login Form) ที่ยืดหยุ่นปรับขนาดอัตโนมัติแบบโปรแกรมมิ่ง (Programmatic UI) โดยใช้ตัวจัดการเลย์เอาต์ `jgd-forms-layout`

---

## Layout Structure / การตั้งค่าตารางเลย์เอาต์

The form defines a grid with 3 columns and 7 rows:
ตารางเลย์เอาต์ถูกแบ่งออกเป็น 3 คอลัมน์ และ 7 แถว ดังนี้:

*   **Column Specs**: `right:pref, 6dlu, fill:100dlu:grow`
    1.  **Col 1**: Right-aligned labels (`right:pref`).
    2.  **Col 2**: Gap of 6 Dialog Units (`6dlu`).
    3.  **Col 3**: Growing input fields, filling client area (`fill:100dlu:grow`).
*   **Row Specs**: `pref, 12dlu, pref, 6dlu, pref, 12dlu, pref`
    1.  **Row 1**: Form title header (`pref`).
    2.  **Row 2**: Vertical gap of 12 Dialog Units (`12dlu`).
    3.  **Row 3**: Username field (`pref`).
    4.  **Row 4**: Vertical gap of 6 Dialog Units (`6dlu`).
    5.  **Row 5**: Password field (`pref`).
    6.  **Row 6**: Vertical gap of 12 Dialog Units (`12dlu`).
    7.  **Row 7**: Login and Cancel buttons panel (`pref`).

---

## How to Build / วิธีคอมไพล์

You can compile this project using `lazbuild` from the command line:
คุณสามารถคอมไพล์โครงการนี้ได้โดยเรียกใช้ `lazbuild` ผ่าน Terminal:

```powershell
& "C:\Users\sjedt\LazarusFPC\lazarus-4.6-0\lazbuild.exe" "LoginForm.lpi"
```

The compiled binary will be generated under `lib/x86_64-win64/LoginForm.exe`.
ไฟล์ประมวลผลที่ผ่านการคอมไพล์แล้วจะอยู่ใน `lib/x86_64-win64/LoginForm.exe`
