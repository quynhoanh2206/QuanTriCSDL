USE master;

IF EXISTS(SELECT * FROM sys.databases WHERE name = 'QuanLyNhanSu')
BEGIN
    ALTER DATABASE [QuanLyNhanSu] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE [QuanLyNhanSu];
END
GO

CREATE DATABASE [QuanLyNhanSu]
GO

USE [QuanLyNhanSu]
GO

-- Table: QuanLy
CREATE TABLE QuanLy (
    Taikhoan VARCHAR(25) PRIMARY KEY NOT NULL,
    Matkhau VARCHAR(10) NOT NULL
);

-- Table: ChucVu
CREATE TABLE ChucVu (
    MaChucVu CHAR(7) NOT NULL PRIMARY KEY,  
    ChucVu NVARCHAR(25) NOT NULL,
	LuongTheoGio INT NOT NULL
);

-- Table: NhanVien
CREATE TABLE NhanVien (
    MaNV CHAR(7) PRIMARY KEY NOT NULL, 
    Hovaten NVARCHAR(50) NOT NULL,
    Sodienthoai CHAR(10),
    Gioitinh BIT,
    Diachi NVARCHAR(150),
    Ngaythangnamsinh DATE,
    MaChucVu CHAR(7) NOT NULL, 
    FOREIGN KEY (MaChucVu) REFERENCES ChucVu(MaChucVu)
);
-- Table: UngLuong
CREATE TABLE UngLuong (
    MaUngLuong CHAR(7) NOT NULL PRIMARY KEY, 
    MaNV CHAR(7) NOT NULL, 
    NgayUng DATE,
    SoTien FLOAT,
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);
-- Table: PhanCongCaLamViec
CREATE TABLE PhanCongCaLamViec (
    MaPhanCong CHAR(7) NOT NULL PRIMARY KEY, 
    MaNV CHAR(7) NOT NULL,
    NgayThangNamLamViec DATE,
	TenCa nvarchar(10),
    Thoigianvaoca TIME,
    Thoigianketca TIME,
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

-- Table: BangChamCongChiTiet
CREATE TABLE BangChamCong (
    MaChamCong CHAR(7) PRIMARY KEY  NOT NULL,  
    MaNV CHAR(7) NOT NULL, 
    NgayThangNam DATE,
    GioDiLam TIME,
    GioRaVe TIME,
    SoGioLam FLOAT,
    SoPhutTre FLOAT,
	Phat FLOAT,
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);

-- Table: BangLuong
CREATE TABLE BangLuong (
    MaLuong CHAR(7) NOT NULL PRIMARY KEY,
    MaNV CHAR(7) NOT NULL,  
    ThangNamLuong DATE,
    LuongCT DECIMAL(10,2),
    FOREIGN KEY (MaNV) REFERENCES NhanVien(MaNV)
);


INSERT INTO QuanLy (Taikhoan, Matkhau) VALUES
('admin01', 'pass12345');  

INSERT INTO ChucVu (MaChucVu, ChucVu, LuongTheoGio) VALUES
('CV01', N'Bếp trưởng', 50000),
('CV02', N'Phụ bếp', 20000),
('CV03', N'Nhân viên', 20000),
('CV04', N'Phục vụ', 20000),
('CV05', N'Quản lý', 50000),
('CV06', N'Đầu bếp', 50000);

CREATE OR ALTER PROCEDURE ThemNhanVien 
AS
BEGIN
    DECLARE @ho TABLE (ho NVARCHAR(50))
    DECLARE @tendem TABLE (tendem NVARCHAR(50))
    DECLARE @ten TABLE (ten NVARCHAR(50))
    DECLARE @diachi TABLE (diachi NVARCHAR(150))

    INSERT INTO @ho VALUES  
        (N'Nguyễn'), (N'Trần'), (N'Lê'), (N'Phạm'), (N'Võ'), 
        (N'Bùi'), (N'Hoàng'), (N'Huỳnh')

    INSERT INTO @tendem VALUES  
        (N'Văn'), (N'Thị'), (N'Hữu'), (N'Minh'), (N'Ngọc'), (N'Kim')

    INSERT INTO @ten VALUES  
        (N'Minh'), (N'Lan'), (N'Hoa'), (N'Tuấn'), (N'Hiền'), 
        (N'Hoàng'), (N'An'), (N'Khoa'), (N'Thảo'), (N'Nam'), 
        (N'Ly'), (N'Thảo')

    INSERT INTO @diachi VALUES  
        (N'Số 12, Đường Trần Phú, Quận Hải Châu, TP Đà Nẵng'),
        (N'Số 45, Đường Phan Chu Trinh, Quận Sơn Trà, TP Đà Nẵng'),
        (N'Thôn Phú Lộc, Xã Hòa Khánh, TP Đà Nẵng'),
        (N'Số 18, Đường Hùng Vương, Phường Phú Nhuận, TP Huế'),
        (N'Số 67, Đường Nguyễn Hữu, Phường Thuận Thành, TP Huế'),
        (N'Thôn Đồng An, Xã Tam Nghĩa, Huyện Núi Thành, Quảng Nam'),
        (N'Thôn Trung Lộc, Xã Điện Thắng, Huyện Điện Bàn, Quảng Nam'),
        (N'Thôn Bắc Sơn, Xã Gio Việt, Huyện Gio Linh, Quảng Trị'),
        (N'Số 123, Đường Quang Trung, Phường 1, Thị xã Quảng Trị, Quảng Trị')

    DECLARE @i INT = 1

    WHILE @i <= 1000
    BEGIN
        DECLARE @manvmoi CHAR(7) = 'NV' + RIGHT('00000' + CAST(@i AS VARCHAR(5)), 5)
       
        INSERT INTO NhanVien (MaNV, Hovaten, Sodienthoai, Gioitinh, Diachi, Ngaythangnamsinh, MaChucVu)
        VALUES 
        (
            @manvmoi,
            (SELECT TOP 1 ho FROM @ho ORDER BY NEWID()) + ' ' + 
            (SELECT TOP 1 tendem FROM @tendem ORDER BY NEWID()) + ' ' +
            (SELECT TOP 1 ten FROM @ten ORDER BY NEWID()),
            '0' + RIGHT(CAST(ABS(CHECKSUM(NEWID())) % 10000000000 AS VARCHAR(10)), 9),
            CASE WHEN @i % 2 = 0 THEN 1 ELSE 0 END,
            (SELECT TOP 1 diachi FROM @diachi ORDER BY NEWID()),
            DATEADD(YEAR, -(18 + ABS(CHECKSUM(NEWID())) % 32), GETDATE()),
            (SELECT TOP 1 MaChucVu FROM ChucVu ORDER BY NEWID())
        )

        SET @i += 1
    END

    PRINT N'Thêm dữ liệu nhân viên thành công'
END

EXEC ThemNhanVien;

-- Thêm ứng lương
CREATE OR ALTER PROCEDURE ThemUngLuong 
AS
BEGIN
    DECLARE @manv CHAR(7);
    DECLARE @maungluong CHAR(7);
    DECLARE @ngayung DATE;
    DECLARE @sotien FLOAT;

    DECLARE @i INT = 1;

    WHILE @i <= 1000
    BEGIN
        SET @maungluong = 'UL' + RIGHT('00000' + CAST(@i AS VARCHAR(5)), 5);
        
        SET @manv = (SELECT TOP 1 MaNV FROM NhanVien ORDER BY NEWID());

        SET @ngayung = DATEADD(DAY, ((@i - 1) % 30), '2024-01-01');
        
        SET @sotien = (ABS(CHECKSUM(NEWID()) % 500000) + 500000);  

        INSERT INTO UngLuong (MaUngLuong, MaNV, NgayUng, SoTien) 
        VALUES (@maungluong, @manv, @ngayung, @sotien);

        SET @i += 1;
    END

    PRINT N'Thêm dữ liệu ứng lương thành công';
END

-- Chạy thủ tục
EXEC ThemUngLuong;


-- phân công
CREATE OR ALTER PROCEDURE ThemPhanCongCaLamViec
AS
BEGIN
    DECLARE @n INT = 1;
    DECLARE @maphancong CHAR(7);
    DECLARE @manv CHAR(7);
    DECLARE @ngaythang DATE;
    DECLARE @tenca NVARCHAR(10);
    DECLARE @thoigianvaoca TIME;
    DECLARE @thoigianketca TIME;

    WHILE @n <= 30000
    BEGIN

        SET @manv = 'NV' + RIGHT('00000' + CAST(ABS(CHECKSUM(NEWID()) % 1000) + 1 AS VARCHAR(5)), 5);

        SET @ngaythang = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 30), '2024-01-01');

       -- (Ca 1: 07:00-12:00, Ca 2: 12:00-17:00, Ca 3: 17:00-23:00)
        DECLARE @ca INT = ABS(CHECKSUM(NEWID()) % 3) + 1;
        IF @ca = 1
        BEGIN
            SET @tenca = 'Ca 1';
            SET @thoigianvaoca = '07:00:00';
            SET @thoigianketca = '12:00:00';
        END
        ELSE IF @ca = 2
        BEGIN
            SET @tenca = 'Ca 2';
            SET @thoigianvaoca = '12:00:00';
            SET @thoigianketca = '17:00:00';
        END
        ELSE
        BEGIN
            SET @tenca = 'Ca 3';
            SET @thoigianvaoca = '17:00:00';
            SET @thoigianketca = '23:00:00';
        END

        SET @maphancong = 'PC' + RIGHT('00000' + CAST(@n AS VARCHAR(5)), 5);

        -- Insert into PhanCongCaLamViec
        INSERT INTO PhanCongCaLamViec (MaPhanCong, MaNV, NgayThangNamLamViec, TenCa, Thoigianvaoca, Thoigianketca)
        VALUES (@maphancong, @manv, @ngaythang, @tenca, @thoigianvaoca, @thoigianketca);

        SET @n += 1;
    END

    PRINT N'Đã thêm 30,000 dòng dữ liệu vào bảng PhanCongCaLamViec thành công';
END;

--
EXEC ThemPhanCongCaLamViec

-- cham công
CREATE OR ALTER PROCEDURE DumpBangChamCongChiTiet
AS
BEGIN
    DECLARE @machamcong CHAR(7);
    DECLARE @manv CHAR(7);
    DECLARE @ngaythang DATE;
    DECLARE @giodilam TIME;
    DECLARE @giorave TIME;
    DECLARE @thoigianvaoca TIME;
    DECLARE @thoigianketca TIME;
    DECLARE @delay_in_minutes INT;
    DECLARE @n INT = 1;

    DECLARE cur CURSOR FOR
    SELECT MaNV, NgayThangNamLamViec, Thoigianvaoca, Thoigianketca
    FROM PhanCongCaLamViec;

    OPEN cur;
    FETCH NEXT FROM cur INTO @manv, @ngaythang, @thoigianvaoca, @thoigianketca;

    WHILE @@FETCH_STATUS = 0 AND @n <= 30000
    BEGIN
        SET @delay_in_minutes = ABS(CHECKSUM(NEWID()) % 31);

     
        SET @giodilam = DATEADD(MINUTE, @delay_in_minutes * (CASE WHEN CHECKSUM(NEWID()) % 2 = 0 THEN 1 ELSE -1 END), @thoigianvaoca);
        SET @giorave = DATEADD(MINUTE, @delay_in_minutes * (CASE WHEN CHECKSUM(NEWID()) % 2 = 0 THEN 1 ELSE -1 END), @thoigianketca);

        SET @machamcong = 'CC' + RIGHT('00000' + CAST(@n AS VARCHAR(5)), 5);

        INSERT INTO BangChamCong (MaChamCong, MaNV, NgayThangNam, GioDiLam, GioRaVe)
        VALUES (@machamcong, @manv, @ngaythang, @giodilam, @giorave);

        FETCH NEXT FROM cur INTO @manv, @ngaythang, @thoigianvaoca, @thoigianketca;

        SET @n += 1;
    END

    CLOSE cur;
    DEALLOCATE cur;

    PRINT N'Đã thêm 30,000 dòng dữ liệu vào bảng BangChamCong thành công';
END;

-- Chạy thủ tục
EXEC DumpBangChamCongChiTiet;


-- Bang luong
CREATE OR ALTER PROCEDURE DumpBangLuong
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @MaLuong CHAR(7);
    DECLARE @MaNV CHAR(7);
    DECLARE @ThangNamLuong DATE;

    SET @ThangNamLuong = '2024-01-01'; 

    WHILE @i <= 1000
    BEGIN
        SET @MaLuong = 'ML' + RIGHT('00000' + CAST(@i AS VARCHAR(5)), 5); 
        SET @MaNV = 'NV' + RIGHT('00000' + CAST(@i AS VARCHAR(5)), 5); 

        INSERT INTO BangLuong (MaLuong, MaNV, ThangNamLuong)
        VALUES (@MaLuong, @MaNV, @ThangNamLuong);

        SET @i = @i + 1;
    END
END;

EXEC DumpBangLuong;



SELECT*FROM QuanLy
SELECT*FROM ChucVu
SELECT*FROM NhanVien
SELECT*FROM BangLuong
SELECT*FROM BangChamCong
SELECT*FROM PhanCongCaLamViec
select*from UngLuong
TRUNCATE TABLE BangChamCong
SELECT COUNT(*) FROM BangChamCong;
SELECT COUNT(*) FROM PhanCongCaLamViec;
SELECT COUNT(*) FROM BangLuong;
SELECT COUNT(*) FROM UngLuong



-- MODULE 1 : Tính SoGioLam và tiền Phat ở bảng ChamCong
--Phân tích: 
--input: giờ đi làm, giờ ra về
--output: N/A
/*process:
cập nhật số giờ làm, số phút trễ, phạt vào bảng chấm công
Tính số giờ làm của nhân viên = giờ ra về  - giờ ra về
Tính số phút trễ của nhân viên:
Nếu giờ đi làm - giờ vào ca > 0 thì tính số phút trễ. Thì cập nhật:
Số phút trễ = giờ đi làm - giờ vào ca
Ngược  lại thì cập nhật số phút trễ = 0
Tính phạt:
	Phạt = số phút trễ * 1000
*/
 
CREATE OR ALTER PROCEDURE TinhSoGioLamVaSoGioTre
AS
BEGIN
    DECLARE @sogiolam INT;
    DECLARE @sophuttre INT;
    DECLARE @phat DECIMAL(10, 2);

    UPDATE BangChamCong
    SET 
        @sogiolam = DATEDIFF(HOUR, GioDiLam, GioRaVe),
        @sophuttre = CASE 
                        WHEN DATEDIFF(MINUTE, pc.Thoigianvaoca, bc.GioDiLam) > 0 
                        THEN DATEDIFF(MINUTE, pc.Thoigianvaoca, bc.GioDiLam) 
                        ELSE 0 
                     END,
        @phat = @sophuttre * 1000,
        SoGioLam = @sogiolam,
        SoPhutTre = @sophuttre,
        Phat = @phat
    FROM BangChamCong bc
    JOIN PhanCongCaLamViec pc ON bc.MaNV = pc.MaNV AND bc.NgayThangNam = pc.NgayThangNamLamViec;

    PRINT N'Đã tính toán SoGioLam, SoPhutTre và Phat thành công'
END;
-- chạy thủ tục
EXEC TinhSoGioLamVaSoGioTre
-- kiểm tra kết quả
SELECT*FROM BangChamCong


--MODULE 2: Tinh Lương mỗi tháng của mỗi nhân viên
/* Phân tích:
input: số giờ làm, phạt
output: N/A
Process:
Cập nhật bảng lương:
Tính tổng số giờ làm việc từ bảng chấm công
Tính tổng phạt từ bảng chấm công
Tính lương chính thức 
Lương chính thức = (Tổng số giờ làm * Lương theo giờ (lấy ở bảng chức vụ) ) - Tổng phạt
nối bảng lương chính thức với bảng nhân viên
nối bảng nhân viên với bảng chức vụ */

CREATE OR ALTER PROCEDURE TinhBangLuong
AS
BEGIN
    DECLARE @tongSoGioLam DECIMAL(15, 2);
    DECLARE @tongPhat DECIMAL(15, 2);
    DECLARE @luongct DECIMAL(15, 2);

    UPDATE bl
    SET 
        @tongSoGioLam = (SELECT SUM(SoGioLam) FROM BangChamCong WHERE MaNV = bl.MaNV),
        @tongPhat = (SELECT SUM(Phat) FROM BangChamCong WHERE MaNV = bl.MaNV),
        @luongct = (@tongSoGioLam * cv.LuongTheoGio) - @tongPhat,
        LuongCT = @luongct
    FROM BangLuong bl JOIN  NhanVien nv on nv.MaNV = bl.MaNV
    JOIN ChucVu cv ON cv.MaChucVu = nv.MaChucVu

    PRINT N'Đã tính toán bảng lương thành công';
END;
-- chạy thủ tục
EXEC TinhBangLuong;
-- kiểm tra kết quả
SELECT * FROM BangLuong;

-- MODULE 3:  "Kiểm tra thông tin trước khi thêm vào bảng chấm công"

/*phân tích
I: MaNV,NgayThangNam,GioDiLam,GioRave,SoGioLam,SoGioTre
O: Trả về 0 ( nếu ngày chấm công không hợp lệ hoặc nhân viên không tồn tại)
   trả về 1 nếu thông tin hợp lệ và bản ghi đã được thêm vào bảng BangChamCong
P: 
1. kiểm tra sự tồn tại của nhân viên:
	1.1 @count=SELECT COUNT(*) từ BangNhanVien, điều kiện MaNV=@MaNV
	1.2 if @count=0 -> trả về 0
2. Kiểm tra tính hợp lệ của ngày chấm công
if @NgayThangNam NULL hoặc > getdate() -> trả về 0
3. Kiểm tra xem đã có bản ghi chấm công nào cho nhân viên đó vào cùng ngày chưa
if EXISTS (SELECT 1 FROM BangChamCongChiTiet), điều kiện MaNV = @MaNV AND NgayThangNam = @NgayThangNam
-> trả về 0
4.  Kiểm tra xem giờ ra về có hợp lý hơn giờ đi làm không
if @GioRaVe < @GioDiLam -> trả về 0
5.  Kiểm tra số giờ làm và số giờ trễ có hợp lý không (dưới 24 giờ)
IF @SoGioLam < 0 OR @SoGioLam >= 24 -> trả về 0
6. Nếu tất cả các trường hợp hợp lêj
-> thêm bản ghi mới vào bảng BamChamCong
	6.1 Thực hiện thêm bản ghi mới vào bảng BangChamCong
	6.2 Sau đó, trả về 1
*/

CREATE OR ALTER PROCEDURE KiemTraVaThemChamCongChiTiet 
    @MaNV CHAR(7),
    @NgayThangNam DATE,
    @GioDiLam TIME,
    @GioRaVe TIME,
    @SoGioLam FLOAT,
    @SoGioTre FLOAT
AS
BEGIN
 
    DECLARE @ErrorMessage NVARCHAR(200);

    -- Kiểm tra xem mã nhân viên có tồn tại trong bảng NhanVien hay không
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE MaNV = @MaNV)
    BEGIN
        SET @ErrorMessage = N'Mã nhân viên không tồn tại';
        PRINT @ErrorMessage;
        RETURN 0;  -- Trả về 0 khi không hợp lệ
    END

    -- Kiểm tra tính hợp lệ của ngày chấm công (có thể thêm điều kiện cụ thể về ngày tháng)
    IF @NgayThangNam IS NULL  OR @NgayThangNam > GETDATE()
    BEGIN
        SET @ErrorMessage = N'Ngày chấm công không hợp lệ';
        PRINT @ErrorMessage;
        RETURN 0;  -- Trả về 0 khi không hợp lệ
    END

    -- Kiểm tra xem đã có bản ghi chấm công nào cho nhân viên đó vào cùng ngày chưa
    IF EXISTS (SELECT 1 FROM BangChamCong WHERE MaNV = @MaNV AND NgayThangNam = @NgayThangNam)
    BEGIN
        SET @ErrorMessage = N'Nhân viên đã được chấm công vào ngày này';
        PRINT @ErrorMessage;
        RETURN 0;  -- Trả về 0 khi không hợp lệ
    END

    -- Kiểm tra xem giờ ra về có hợp lý hơn giờ đi làm không
    IF @GioRaVe <= @GioDiLam
    BEGIN
        SET @ErrorMessage = N'Giờ ra về phải lớn hơn giờ đi làm';
        PRINT @ErrorMessage;
        RETURN 0;  -- Trả về 0 khi không hợp lệ
    END

    -- Kiểm tra số giờ làm và số giờ trễ có hợp lý không (dưới 24 giờ)
    IF @SoGioLam < 0 OR @SoGioLam >= 24
    BEGIN
        SET @ErrorMessage = N'Số giờ làm không hợp lệ (phải từ 0 đến 24)';
        PRINT @ErrorMessage;
        RETURN 0;  -- Trả về 0 khi không hợp lệ
    END

    IF @SoGioTre < 0 OR @SoGioTre >= 24
    BEGIN
        SET @ErrorMessage = N'Số giờ trễ không hợp lệ (phải từ 0 đến 24)';
        PRINT @ErrorMessage;
        RETURN 0;  -- Trả về 0 khi không hợp lệ
    END

    -- Nếu tất cả các kiểm tra hợp lệ, thêm dữ liệu vào bảng BangChamCongChiTiet
    INSERT INTO BangChamCong (MaChamCong, MaNV, NgayThangNam, GioDiLam, GioRaVe, SoGioLam, SoPhutTre)
    VALUES (
        'CC' + RIGHT('0000' + CAST((SELECT COUNT(*) FROM BangChamCong) + 1 AS VARCHAR(4)), 4), -- Tạo MaChamCong tự động
        @MaNV, 
        @NgayThangNam, 
        @GioDiLam, 
        @GioRaVe, 
        @SoGioLam, 
        @SoGioTre
    );

    PRINT N'Thêm dữ liệu chấm công thành công';
    RETURN 1;  -- Trả về 1 khi bản ghi đã được thêm thành công
END;

-- chạy thủ tục
DECLARE @Result INT;

EXEC @Result = KiemTraVaThemChamCongChiTiet 
    @MaNV = 'NV001',
    @NgayThangNam = '2024-10-16',
    @GioDiLam = '08:00',
    @GioRaVe = '17:00',
    @SoGioLam = 8,
    @SoGioTre = 0;


-- MODULE 4: Kiểm tra các điều kiện trước khi duyệt lương
/*
- input: N/A
- output: 
	+ Trả về 0 nều nhân viên chấm công không đầy đủ hoặc dữ liệu bản chấm công bị lỗi, lương không được duyệt
	+ Trả về 1 nếu tất cả dữ liệu được kiểm tra và không có lỗi, lương được duyệt
- process: 
	1. Kiểm tra sự tổn tại của dữ liệu chấm công 
		- Chọn 1 bản ghi của Bangluong kết hợp với BangChamCongChiTiet với điều kiện MaNV của BangChamCongChiTiet trống, không có dữ liệu
			+ Nếu tồn tại bản ghi với điều kiện BangChamCongChiTiet trống, không có dữ liệu thì trả về  0 và kết thúc thủ tục
	2. Kiểm tra tính đầy đủ của dữ liệu chấm công
		- Chọn 1 bản ghi từ BangChamCongChiTiet với điều kiện GioDiLam trống hoặc GioRaVe trống
			+ Kiểm tra nếu tồn tại với điều kiện GioDiLam trống hoặc GioRaVe trống thì trả về  0 và kết thúc thủ tục
	3. Nếu không tồn tại 2 trường hợp trên thì trả về 1 để thông báo lương được duyệt
*/

CREATE PROC Checkdkduyetluong (@ref NVARCHAR(300) OUTPUT)
AS
BEGIN
	IF EXISTS(SELECT 1 
		FROM BangLuong JOIN BangChamCong ON BangLuong.MaNV = BangChamCong.MaNV
		WHERE BangChamCong.MaNV is null) --Điều kiện: Mã nhân viên của BangChamCong trống
	BEGIN
		SET @ref = N'Nhân viên chưa chấm công đầy đủ, không duyệt lương'
		RETURN
	END
	ELSE IF EXISTS(SELECT 1 
					FROM BangChamCong
					WHERE GioDiLam IS NULL 
					OR GioRaVe IS NULL)
	BEGIN
		SET @ref = N'Dữ liệu lỗi, không thể duyệt lương'
		RETURN
	END
	ELSE
	BEGIN
		SET @ref = N'Tất cả đã được kiểm tra, lương có thể được duyệt'
	END
END
--chạy thủ tục
DECLARE @A NVARCHAR(300)
EXEC Checkdkduyetluong @A OUTPUT
PRINT @A
select * from BangChamCong

-- MODULE 5:  Kiểm tra lương âm khi cập nhật bảng lương
/*
-- Loại trigger: after (for)
- Sự kiện kích hoạt: insert, update
- Kí sinh trên bảng: Bangluong
- Quy trình xử lý: 
	1. Chọn 1 bản ghi trong bảng inserted. Điều kiện: LuongCT < 0 
	2. Kiểm tra sự tồn tại của bản ghi đó:
		a. Nếu tồn tại thì in ra giá trị chuỗi: 'Lỗi!! Lương không được nhỏ hơn 0' và huỷ thao tác thực hiện
		b. Nếu không tồn tại thì sẽ không thực hiện bước nào thêm và quá trình INSERT hoặc UPDATE sẽ tiếp tục thành công. 
*/
 
CREATE OR ALTER TRIGGER Checkluongam
ON Bangluong
FOR INSERT, UPDATE
AS
BEGIN
	IF EXISTS (SELECT 1 FROM inserted 
				WHERE LuongCT < 0) 
	BEGIN
		PRINT N'Lỗi!! Lương không được nhỏ hơn 0'
		ROLLBACK
	END
END
SELECT * FROM BangLuong

-- thêm dữ liệu mới 
INSERT INTO BangLuong (MaLuong, MaNV, ThangNamLuong, LuongCT)
VALUES('SL00001', 'NV00928', '2022-08-01', '1000') -- thêm dữ liệu thành công

INSERT INTO BangLuong (MaLuong, MaNV, ThangNamLuong, LuongCT)
VALUES('AT00001', 'NV00912', '2022-08-01', '-1000') -- thêm dữ liệu không thành công

--cập nhật lương
UPDATE BangLuong SET LuongCT = '-5000' WHERE MaLuong = 'ML00001' -- Lương <0 nên cập nhật không thành công

UPDATE BangLuong SET LuongCT = '5000' WHERE MaLuong = 'ML00001' --Lương >0 nên cập nhật thành công

--xoá trigger
DROP TRIGGER Checkluongam


--MODULE 6: "Tạo module thực hiện các công việc dưới đây khi thêm mới nhân viên"
/* Phân tích:
- Input: 
    + @MaNV 
    + @Hovaten 
    + @Sodienthoai 
    + @Gioitinh
    + @Diachi 
    + @Ngaythangnamsinh 
    + @MaChucVu 
    
- Output: trả về 1 nếu tất cả các thông tin hợp lệ. ngược lại trả về 0
- Process:
    1.  -Kiểm tra độ dài mã nhân viên. 
			if (@MaNV) <> -> print N'Mã nhân viên phải có 7 ký tự' + kết thúc -> @ret=0
    2. Kiểm tra độ dài số điện thoại
		  IF LEN(@Sodienthoai) <> 10 -> print N'Số điện thoại phải có đúng 10 ký tự' -> @ret=0
	3. Kiểm tra xem mã chức vụ có tồn tại trong bảng ChucVu không.Nếu mã chức vụ không tồn tại thì thông báo lỗi và kết thúc.
		IF (@MaChucVu not in (select MaChucVu from ChucVu, dieu kien MaChucVu=@MaChucVu)
		-> print N'Ma Chuc Vu Khong Ton Tai' + ket thuc -> @ret=0
	4. -- d.Kiểm tra xem mã nhân viên đã tồn tại chưa. Nếu mã nhân viên đã tồn tại thì thông báo và kết thúc
		IF (@MaNV not in (select MaNV from NhanVien, dieu kien MaNV=@MaNV)
		-> print N'Ma nhan vien Khong Ton Tai' + ket thuc -> @ret=0
	5. nếu tất cả các thông tin đều hợp lệ -> thêm mới nhân viên vào bảng Nhanvien -> @ret=1
*/

CREATE OR ALTER PROCEDURE KiemTraVaCapNhatNhanVien
    @MaNV CHAR(7),
    @Hovaten NVARCHAR(50),
    @Sodienthoai CHAR(10),
    @Gioitinh BIT,
    @Diachi NVARCHAR(150),
    @Ngaythangnamsinh DATE,
    @MaChucVu CHAR(7),
	@ret bit output
AS
BEGIN

    --a. Kiểm tra độ dài mã nhân viên. Nếu độ dài mã khác 7 kí tự thì thông báo lỗi và kết thúc.
    IF LEN(@MaNV) <> 7
    BEGIN
        PRINT 'Mã nhân viên phải có 7 ký tự.'
		set @ret=0
        RETURN;
    END

    --b. Kiểm tra độ dài số điện thoại. Nếu độ dài số điện thoại không bằng 10 thì thông báo lỗi và kết thúc.
    IF LEN(@Sodienthoai) <> 10
    BEGIN
        print N'Số điện thoại phải có đúng 10 ký tự.';
		set @ret=0;
        RETURN;
    END
    
    --c. Kiểm tra xem mã chức vụ có tồn tại trong bảng ChucVu không. Nếu mã chức vụ không tồn tại thì thông báo lỗi và kết thúc.
    IF @MaChucVu not in (select MaChucVu from ChucVu where MaChucVu=@MaChucVu)
    BEGIN
        PRINT N'Mã chức vụ không tồn tại.';
		set @ret=0;
        RETURN;
    END

    -- d.Kiểm tra xem mã nhân viên đã tồn tại chưa. Nếu mã nhân viên đã tồn tại thì thông báo và kết thúc
    IF @MaNV not in (select MaNV from NhanVien where MaNV=@MaNV)
    BEGIN
        PRINT N'Mã nhân viên đã tồn tại.'
		set @ret=0;
		return 
    END
 
     --e. Thêm mới nhân viên

     INSERT INTO NhanVien (MaNV, Hovaten, Sodienthoai, Gioitinh, Diachi, Ngaythangnamsinh, MaChucVu)
     VALUES (@MaNV, @Hovaten, @Sodienthoai, @Gioitinh, @Diachi, @Ngaythangnamsinh, @MaChucVu);
        
      PRINT N'Đã thêm mới nhân viên thành công';
	  set @ret=1;
END;

-- chạy thủ tục
DECLARE @r bit;
EXEC KiemTraVaCapNhatNhanVien 
    @MaNV = 'NV00123',  
    @Hovaten = N'Nguyễn Văn A',
    @Sodienthoai = '0123456789',
    @Gioitinh = 1, 
    @Diachi = N'Hà Nội',
    @Ngaythangnamsinh = '1990-01-01',
    @MaChucVu = 'CV00123',
    @ret = @r OUTPUT;
PRINT @r;

-- MODULE 7: Kiểm tra việc trùng lịch khi phân công ca làm việc
/*
-- trigger
-- loại trigger: after
-- sự kiện: insert
-- kí sinh: PhanCongCaLamViec
-- xử lý: 
	kiểm tra trùng lịch
	1. nếu tồn tại  thoigianvaoca và thoigianketca ở bảng inserted = 
	thoigianvaoca và thoigianketca ở bảng PhanCongCaLamviec, điều kiện @MaNV=MaNV
	
*/
CREATE OR ALTER TRIGGER tr_kiem_tra_trung_lich
ON PhanCongCaLamViec
AFTER INSERT
AS
BEGIN
    -- Kiểm tra trùng lịch
    IF EXISTS (
        SELECT 1
        FROM PhanCongCaLamViec pc
        INNER JOIN inserted i ON pc.MaNV = i.MaNV AND pc.NgayThangNamLamViec = i.NgayThangNamLamViec
        WHERE 
            (pc.Thoigianvaoca < i.Thoigianketca AND pc.Thoigianketca > i.Thoigianvaoca)
    )
    BEGIN
        PRINT N'Trùng lịch phân công ca làm việc!'
        ROLLBACK TRANSACTION; -- Hoàn tác nếu có trùng lịch
    END
END;

-- Test
TRUNCATE TABLE PhanCongCaLamViec;
INSERT INTO PhanCongCaLamViec (MaPhanCong, MaNV, NgayThangNamLamViec, Thoigianvaoca, Thoigianketca)
VALUES ('PC00001', 'NV00126', '2025-05-04', '08:32:00', '16:25:00');  -- Đây sẽ là ca trùng lịch


-- MODULE 8 : Kiểm tra số lần ứng lương và mức lương ứng

/* Phân tích: 
- input: Mã nhân viên và số tiền ứng
- output: 
	1. Nếu số lần ứng quá 3 lần thì trả về dạng chuỗi: "Nhân viên đã ứng lương đủ 3 lần, không thể ứng thêm."
	2. Nếu số tiền ứng không nằm trong mức từ 500000 - 1000000 thì 
	trả về giá trị dạng chuỗi: "Không được ứng lương!! Số tiền ứng phải nằm trong khoảng từ 500.000 đến 100.000.000."
	3. Nếu thoả mãn 2 điều kiện trên thì trả về dạng chuỗi: "Nhân viên có thể ứng lương."
-- Process: 
	1. Tìm tên nhân viên theo mã nhân viên
	2. Kiểm tra số lần ứng lương của nhân viên
		a. Nếu số lần ứng lương quá 3 lần thì nhân viên không thể ứng lương và kết thúc thủ tục. 
	3. Kiểm tra số tiền ứng lương của nhân viên.
		a. Nếu số tiền ứng lương của nhân viên < 500000 hoặc > 1000000 thì nhân viên không được ứng lương và kết thúc thủ tục
	4. Nếu 2 điều kiện trên thoả mãn thì nhân viên được ứng lương. 
*/

CREATE OR ALTER PROCEDURE KiemtraUngLuong
    (@MaNV CHAR(7),            -- Mã nhân viên
    @SoTienUng FLOAT,  -- Số tiền ứng lương
    @KetQua NVARCHAR(255) OUTPUT)  -- Biến kết quả đầu ra
AS
BEGIN
    -- Khai báo biến để đếm số lần ứng lương và tổng số tiền đã ứng
    DECLARE @SoLanUngLuong INT;

    -- Kiểm tra số lần ứng lương của nhân viên
    SELECT @SoLanUngLuong = COUNT(*)
    FROM UngLuong
    WHERE MaNV = @MaNV 

    -- Kiểm tra các số lần ứng lương
    IF @SoLanUngLuong >= 3
    BEGIN
        SET @KetQua = N'Nhân viên đã ứng lương đủ 3 lần, không thể ứng thêm.';
        RETURN;
    END

	--Kiểm tra số tiền ứng lương
    IF @SoTienUng < 500000 OR @SoTienUng > 1000000
    BEGIN
        SET @KetQua = N'Không được ứng lương!! Số tiền ứng phải nằm trong khoảng từ 500.000 đến 100.000.000.';
        RETURN;
    END

    -- Nếu vượt qua các kiểm tra, cho phép ứng lương
    SET @KetQua = N'Nhân viên có thể ứng lương.';
END

-- Kiểm tra ứng lương thành công
DECLARE @A NVARCHAR(255)
EXEC KiemtraUngLuong 'NV00001', '700000', @A OUTPUT
PRINT @A

--Kiểm tra ứng lương không thành công
DECLARE @A NVARCHAR(255)
EXEC KiemtraUngLuong 'NV00002', '1200000', @A OUTPUT
PRINT @A

select * from UngLuong
-- MODULE 9: "Kiểm tra tính hợp lệ của các dữ liệu ơ bảng nhân viên, bảng phân công"
/*Input:
Bảng NhanVien(MaNV, Ngaythangnamsin)
Bảng PhanCongCaLamViec:(MaPhanCong, MaNV, NgayThangNamLamViec, Thoigianvaoca, Thoigianketca.)
Bảng UngLuong:(MaUngLuong, MaNV, SoTien, NgayUng) 
Output: Nếu có thông tin không hợp lệ: sẽ in ra thông báo tương ứng và trả về 0.
Nếu tất cả thông tin hợp lệ: sẽ in ra "Tất cả thông tin đều hợp lệ." và trả về 1.
Process: 
1.Kiểm Tra Bảng NhanVien
	1.1. Kiểm tra ngày sinh: Ngày sinh phải nhỏ hơn ngày hiện tại. ->Ngaythangnamsinh >= GETDATE()
2.Kiểm Tra Bảng PhanCongCaLamViec
	2.1 Thời gian vào ca: Thời gian vào ca phải nhỏ hơn thời gian kết ca -> Thoigianvaoca >= Thoigianketca
	2.2 Ngày làm việc: Ngày làm việc phải nhỏ hơn hoặc bằng ngày hiện tại. -> NgayThangNamLamViec > GETDATE()
3.Kiểm Tra Bảng UngLuong
	3.1 Số tiền ứng: Số tiền ứng phải lớn hơn hoặc bằng 0 -> SoTien < 0
	3.2 Ngày ứng: Ngày ứng phải nhỏ hơn ngày hiện tại. -> NgayUng >= GETDATE()
*/
CREATE OR ALTER PROCEDURE KiemTraTinhHopLe
AS
BEGIN
    DECLARE @countNV INT;
    DECLARE @countPC INT;
    DECLARE @countUL INT;

    SELECT @countNV = COUNT(*) 
    FROM NhanVien
    WHERE Ngaythangnamsinh >= GETDATE();
    
    IF @countNV > 0
    BEGIN
        PRINT N'Thông tin ngày sinh không hợp lệ.';
        RETURN 0; 
    END

    SELECT @countPC = COUNT(*)
    FROM PhanCongCaLamViec
    WHERE Thoigianvaoca >= Thoigianketca;
    
    IF @countPC > 0
    BEGIN
        PRINT N'Thông tin thời gian vào ca không hợp lệ.';
        RETURN 0; 
    END
    
    SELECT @countPC = COUNT(*)
    FROM PhanCongCaLamViec
    WHERE NgayThangNamLamViec > GETDATE();
    
    IF @countPC > 0
    BEGIN
        PRINT N'Thông tin ngày làm việc không hợp lệ.';
        RETURN 0;  
    END

    SELECT @countUL = COUNT(*)
    FROM UngLuong
    WHERE SoTien < 0;
    IF @countUL > 0
    BEGIN
        PRINT N'Thông tin số tiền ứng không hợp lệ.';
        RETURN 0;
    END
    SELECT @countUL = COUNT(*)
    FROM UngLuong
    WHERE NgayUng >= GETDATE();
    
    IF @countUL > 0
    BEGIN
        PRINT N'Thông tin ngày ứng không hợp lệ.';
        RETURN 0; 
    END

    PRINT N'Tất cả thông tin đều hợp lệ.'; 
    RETURN 1;  
END;

-- Thực hiện thủ tục

EXEC KiemTraTinhHopLe;

--MODULE 10: Sua thong tin nhan vien khi biết mã nhân viên
/* Phân tích
- Input: MaNV, Newsdt, NewDiachi
- Output: 
	+ Nếu cập nhật thành công thì trả về giá trị 1
	+ Nếu cập nhật không thành công thì trả về giá trị 0
	+ Nếu MaNV không tồn tại trong bảng NhanVien thì trả về giá trị 0
- Process: 
	1. Kiểm tra sự tồn tại của MaNV trong bảng NhanVien
		+ Nếu tồn tại thì cập nhật số điện thoại và địa chỉ theo mã NV. 
			Cập nhật thành công trả về 1, không thành công thì trả về 0
		+ Nếu không tồn tại thì trả về 0
*/
CREATE OR ALTER PROC SuathongtinNV (@MaNV CHAR(7), @Newsdt CHAR(10), @NewDiachi NVARCHAR(150), @ref BIT OUTPUT)
AS
BEGIN
	IF EXISTS (SELECT  1 FROM NhanVien
				WHERE MaNV = @MaNV)
	BEGIN
		UPDATE Nhanvien
		SET Sodienthoai = @Newsdt, Diachi = @NewDiachi
		WHERE MaNV = @MaNV
		IF @@ROWCOUNT > 0 
			SET @ref = '1'
		ELSE
			SET @ref = '0'
	END
	ELSE
	BEGIN
		SET @ref = '0'
	END
END
--Test thành công
DECLARE @a bit 
EXEC SuathongtinNV 'NV00001', '0375726610', N'Đà Nẵng', @a OUTPUT
PRINT @a
--Test không thành công
DECLARE @a bit 
EXEC SuathongtinNV 'BG00001', '0375726610', N'Đà Nẵng', @a OUTPUT
PRINT @a



--MODULE 11 : Xóa thông tin nhân viên khi biết mã nhân viên
/* Phân tích:
- Input: MaNV
- Output:
    + Nếu xóa thành công thì trả về giá trị 1
    + Nếu xóa không thành công thì trả về giá trị 0
    + Nếu MaNV không tồn tại trong bảng NhanVien thì trả về giá trị 0
- Process:
    1. Kiểm tra sự tồn tại của MaNV trong bảng NhanVien.
        + Nếu tồn tại thì xóa thông tin nhân viên theo mã NV.
            Xóa thành công trả về 1, không thành công thì trả về 0.
        + Nếu không tồn tại thì trả về 0.
*/
CREATE OR ALTER PROC XoaThongTinNV (@MaNV CHAR(7), @ref BIT OUTPUT)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM NhanVien WHERE MaNV = @MaNV)
    BEGIN
        DELETE FROM NhanVien
        WHERE MaNV = @MaNV
        IF @@ROWCOUNT > 0 
            SET @ref = '1'
        ELSE
            SET @ref = '0'
    END
    ELSE
    BEGIN
        SET @ref = '0'
    END
END

--Test
DECLARE @a BIT
EXEC XoaThongTinNV 'BG00001', @a OUTPUT
PRINT @a
