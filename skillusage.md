# Skill Usage Report: jgd-forms-layout Component
# รายงานการประเมินการประยุกต์ใช้ทักษะ (Skill Usage): คอมโพเนนต์ jgd-forms-layout

This report documents the Lazarus IDE and Free Pascal Compiler (FPC) skills applied during the analysis, implementation, and testing of the `jgd-forms-layout` layout manager.

รายงานนี้จัดทำขึ้นเพื่อแสดงรายละเอียดทักษะของ Lazarus IDE และ Free Pascal Compiler (FPC) ที่ถูกนำมาประยุกต์ใช้ในการวิเคราะห์ ออกแบบ พัฒนา และทดสอบตัวจัดการเลย์เอาต์ `jgd-forms-layout`

---

## 📍 Skills Applied / ทักษะที่นำมาประยุกต์ใช้งาน

### 1. Custom Component Development / การพัฒนาคอมโพเนนต์แบบกำหนดเอง
*   **How it was used**: We implemented the layout manager by inheriting from `TCustomPanel` (under LCL) to obtain standard container behavior (borders, colors, child controls parenting). We created a design-time package `jgd_forms_layout.lpk` and configured unit registration in `ujgdformslayoutregister.pas` to place `TJgdFormLayout` under the custom Component Palette tab **"JGoodies"**.
*   **Object Inspector Integration**: Exposed published properties for `ColumnSpecs`, `RowSpecs`, and `ControlConstraints`. We implemented `TJgdFormLayoutControlCollection` inheriting from `TOwnedCollection` and `TJgdFormLayoutControlItem` inheriting from `TCollectionItem` so child control constraints can be managed visually directly within the Lazarus Object Inspector.
*   **การประยุกต์ใช้**: พัฒนาตัวจัดการเลย์เอาต์โดยการสืบทอดคุณสมบัติจาก `TCustomPanel` ของ LCL เพื่อให้ได้คุณลักษณะกล่องบรรจุคอนโทรลลูกมาตรฐาน (เช่น ขอบ, สีพื้นหลัง) และจัดทำแพ็กเกจ `.lpk` พร้อมเขียนขั้นตอนการลงทะเบียนยูนิตใน `ujgdformslayoutregister.pas` เพื่อให้ปรากฏบนแถบเครื่องมือ **"JGoodies"** ใน IDE
*   **การเชื่อมโยงกับ Object Inspector**: นำเสนอคุณสมบัติ `ColumnSpecs`, `RowSpecs` และ `ControlConstraints` ผ่าน `published` properties โดยได้เขียนคอลเลกชัน `TJgdFormLayoutControlCollection` และไอเทม `TJgdFormLayoutControlItem` เพื่อแสดงผลและตั้งค่าพิกัดคอลัมน์/แถวของแต่ละคอนโทรลผ่านแถบ Object Inspector ของ Lazarus ได้โดยตรง

---

### 2. Responsive Desktop UI Layout / การออกแบบ UI ที่ยืดหยุ่นและรองรับหน้าจอทุกขนาด
*   **How it was used**: Implemented the core JGoodies `FormLayout` algorithm inside the overridden `AlignControls` method:
    1.  **Parsing Specs**: Tokenized comma-separated specs (e.g. `'left:pref, 4dlu, fill:pref:grow'`) and resolved alignments (`left`/`l`, `right`/`r`, `center`/`c`, `fill`/`f`), size kinds (`pref`/`p`, `min`/`m`, `default`/`d`, `px`, `dlu`), and grow weights (`grow`/`g` or customized weights like `grow(0.5)`).
    2.  **Surplus Allocation**: Calculated minimum and preferred sizes of columns and rows based on child preferences, then distributed surplus layout width and height to columns/rows that specify grow weights.
    3.  **DLU-to-Pixel Conversion**: Converted Dialog Units (DLUs) to pixels dynamically based on the current font height settings (`Font.Height`), allowing the layout to adjust cleanly under different screen DPI scales.
*   **การประยุกต์ใช้**: นำอัลกอริทึมจัดหน้าจอแบบ `FormLayout` มาเขียนควบคุมพฤติกรรมในเมธอด `AlignControls` ที่ถูก override:
    1.  **การวิเคราะห์ข้อความ Spec**: แยกย่อยข้อความสเปก (เช่น `'left:pref, 4dlu, fill:pref:grow'`) และแปลงเป็นค่า alignment (`l`/`r`/`c`/`f`), ประเภทขนาด (`pref`/`min`/`default`/`px`/`dlu`) และน้ำหนักการยืดขยายคอลัมน์/แถว (`grow(x)`)
    2.  **การกระจายพื้นที่ว่าง**: คำนวณขนาดที่ต้องการของแต่ละคอลัมน์/แถวจากขนาดที่เหมาะสมของคอนโทรลลูก แล้วนำพื้นที่หน้าต่างที่เหลือมาคำนวณกระจายเพิ่มให้กับคอลัมน์/แถวที่มีการตั้งค่า `grow`
    3.  **การแปลงค่า DLU เป็นพิกเซล**: แปลงพิกเซลของค่า Dialog Units (DLU) ตามความสูงของฟอนต์ในขณะนั้น (`Font.Height`) ทำให้รองรับระบบการแสดงผลความละเอียดสูง (High-DPI Scaling) ได้ถูกต้อง

---

### 3. Debugging, Diagnostics & Memory Management / การดีบัก ตรวจวิเคราะห์ และจัดการหน่วยความจำ
*   **How it was used**: 
    1.  **Infinite Loop / Stack Overflow Prevention**: Discovered a critical recursive loop issue where registering child controls dynamically in `AlignControls` triggered a collection `Changed` event, which in turn called `Realign` recursively. Resolved this by introducing a private state flag `FIsAligning: Boolean` as a re-entrancy guard in both `AlignControls` and the collection `Update` handler.
    2.  **Memory Cleanliness**: Ensured that the collection `ControlConstraints` is allocated in the constructor and freed cleanly in the destructor. Used `Notification(opRemove)` to automatically free layout mapping items when parented child controls are destroyed to prevent memory leaks and dangling references.
*   **การประยุกต์ใช้**:
    1.  **การป้องกันปัญหาวงจรรันไม่สิ้นสุด (Stack Overflow)**: ตรวจพบปัญหาการทำงานซ้ำแบบวนลูปไม่มีที่สิ้นสุดจากการลงทะเบียนคอนโทรลลูกในคอลเลกชันระหว่างประมวลผลเลย์เอาต์ ซึ่งระบบเดิมจะไปส่งสัญญาณ `Realign` ย้อนกลับมา แก้ไขโดยใช้แฟล็ก `FIsAligning: Boolean` เป็นด่านป้องกันการประมวลผลซ้อน (Re-entrancy Guard) ทั้งในตัวควบคุมและในตัวอัพเดตคอลเลกชัน
    2.  **การบริหารจัดการหน่วยความจำ**: จัดสรรคอลเลกชันในคอนสตรักเตอร์และเคลียร์ทิ้งในดีสตรักเตอร์ รวมถึงใช้ระบบ `Notification(opRemove)` เพื่อดักจับเมื่อคอนโทรลลูกถูกทำลายและลบข้อมูล constraint ออกจากคอลเลกชันโดยอัตโนมัติ เพื่อป้องกันปัญหา Memory Leak และการอ้างอิงตำแหน่งว่าง (Dangling References)

---

### 4. Unit Testing (FPCUnit) / การทำยูนิตเทส
*   **How it was used**: Developed a dedicated FPCUnit console test project (`test_layout.lpr` and `test_layout.lpi`) inside `tests/` folder:
    *   Designed automated unit tests (`TestColSpecParser`, `TestRowSpecParser`) checking alignment parses, constant sizes, grow weights, abbreviations, and invalid tokens.
    *   Wrote `TestDluConversion` validating DLU-to-pixel conversions at different font height settings.
    *   Ran test compilation and execution via `lazbuild` to confirm all 3 test cases completed successfully with 0 errors and 0 failures.
*   **การประยุกต์ใช้**: พัฒนาชุดทดสอบหน่วยย่อยแบบคอนโซลด้วยเฟรมเวิร์ก FPCUnit (`test_layout.lpr` และ `test_layout.lpi`) ในโฟลเดอร์ `tests/`:
    *   เขียนกรณีทดสอบอัตโนมัติ (`TestColSpecParser`, `TestRowSpecParser`) เพื่อตรวจสอบความถูกต้องของสเปกตัวอักษรย่อ, อักษรเต็ม, ขนาดคงที่, สัดส่วนการยืดขยาย และคำสั่งที่ไม่ถูกต้อง
    *   เขียนกรณีทดสอบ `TestDluConversion` เพื่อตรวจสอบผลลัพธ์การแปลงค่า DLU เป็นพิกเซลเมื่อเปลี่ยนขนาดตัวอักษร
    *   ใช้ `lazbuild` คอมไพล์และทดสอบรันผลจริงเพื่อยืนยันว่าการทดสอบผ่านครบถ้วน (0 errors, 0 failures)

---

### 5. Domain-Driven & Modular Design / สถาปัตยกรรมระดับโมดูลและการออกแบบอิงโดเมน
*   **How it was used**: 
    *   Used Object Pascal records (`TJgdColSpec`, `TJgdRowSpec`) for parsing results to optimize CPU cache locality and reduce memory allocations.
    *   Ensured high cohesion and low coupling by keeping registration logic (`ujgdformslayoutregister.pas`) strictly separated from the layout engine core (`ujgdformslayout.pas`), and separating the test runner suite cleanly into its own subfolder.
*   **การประยุกต์ใช้**:
    *   เลือกใช้โครงสร้างข้อมูลประเภท `record` (`TJgdColSpec`, `TJgdRowSpec`) แทน Class สำหรับจัดเก็บข้อมูลสเปกคอลัมน์/แถวเพื่อเพิ่มประสิทธิภาพการประมวลผลบน RAM และลดภาระ Garbage Collection
    *   แยกยูนิตการลงทะเบียนเมนูคอมโพเนนต์ (`ujgdformslayoutregister.pas`) ออกจากโค้ดหลักของคอมโพเนนต์ (`ujgdformslayout.pas`) เพื่อความง่ายในการย้ายระบบหรือทดสอบ และแยกชุดการทำยูนิตเทสออกไปยังโฟลเดอร์ย่อยอย่างชัดเจน
