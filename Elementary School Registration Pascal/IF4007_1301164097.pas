program ppdbSD;
uses crt, math, sysutils;

const
    S_FNAME  = 'siswa.dat';
    S_ADMINF = 'admin.dat';
    maxSiswa = 75;
    maxJarak = 20;

type siswa = record
    noPeserta : integer;
    nama      : string;
    umur      : string;
    jKelamin  : string;
    alamat    : string;
    nOrtu     : string;
    jarak     : integer;
    diterima  : boolean;
end;

type arraySiswa = array of siswa;

type nFileSiswa = file of siswa;

var
    dataSiswa: arraySiswa;
    fileSiswa: nFileSiswa;
    fileAdmin: file of string;
    isAdmin: boolean;

    // Layar Antarmuka

    procedure saveSiswa();
    var
        i: integer;
    begin
        Assign(fileSiswa, S_FNAME);
        ReWrite(fileSiswa);
        for i:=0 to length(dataSiswa) - 1 do
        begin
            write(fileSiswa, dataSiswa[i]);
        end;
        Close(fileSiswa);
    end;

    procedure init();
    var
        i, size: integer;
        data: siswa;
    begin
        // File initialization
        if FileExists(S_FNAME) then
        begin
            Assign(fileSiswa, S_FNAME);
            Reset(fileSiswa);
            size := FileSize(fileSiswa);
            setLength(dataSiswa, size);
            for i:=0 to size - 1 do
            begin
                Read(fileSiswa, data);
                dataSiswa[i] := data;
            end;
            Close(fileSiswa);
        end;
    end;

    function getAdminPassword():string;
    var
        s: string;
    begin
        if FileExists(S_ADMINF) then
        begin
            Assign(fileAdmin, S_ADMINF);
            Reset(fileAdmin);
            read(fileAdmin, s);
            Close(fileAdmin);
            getAdminPassword := s;
        end
        else
            getAdminPassword := 'tugasbesar';
    end;

    procedure setAdminPassword(pass: string);
    begin
        Assign(fileAdmin, S_ADMINF);
        ReWrite(fileAdmin);
        write(fileAdmin, pass);
        Close(fileAdmin);
    end;

    function count(diterima:boolean): integer;
    var
        ret, i: integer;
    begin
        ret := 0;
        for i:=0 to length(dataSiswa)-1 do
        begin
            if dataSiswa[i].diterima = diterima then
                ret:=ret+1;
        end;
        count := ret;
    end;

    function getnoPesX(id: integer): integer;
    var
        i: integer;
    begin
        i:=0;
        while (dataSiswa[i].noPeserta <> id) and (i < (length(dataSiswa) - 1)) do
            i := i+1;

        if (dataSiswa[i].noPeserta = id) then
            getnoPesX := i
        else
            getnoPesX := -1;
    end;

    function getData(var tabA: arraySiswa; cariQuery: string; cariBy:integer; diterima: boolean) : arraySiswa;
    var
        i: integer;
        n: arraySiswa;
        show: boolean;
    begin
        setLength(n, 0);
        for i:=0 to length(tabA) - 1 do
        begin
            show := false;
            case cariBy of
                0: show := true;
                1: show := (lowercase(tabA[i].nama) = lowercase(cariQuery));
                2: show := (lowercase(tabA[i].alamat) = lowercase(cariQuery));
                3: show := (tabA[i].jarak = strtoint(cariQuery));
            end;
            if show and tabA[i].diterima=diterima then
            begin
                setLength(n, length(n)+1);
                n[length(n)-1] := tabA[i];
            end
        end;
        getData:=n;
    end;

    procedure sort(var tabA: arraySiswa; by, mode: integer);
    var
        j, i, current: integer;
        tmp:siswa;

        q: boolean;
    begin

        for i:=0 to length(tabA)-2 do
        begin
            current := i;
            for j:=i+1 to length(tabA)-1 do
            begin

                case by of
                    1:  if mode = 1 then
                            q:=lowercase(tabA[j].nama) < lowercase(tabA[current].nama)
                        else
                            q:=lowercase(tabA[j].nama) > lowercase(tabA[current].nama);
                    2:  if mode = 1 then
                            q:=lowercase(tabA[j].alamat) < lowercase(tabA[current].alamat)
                        else
                            q:=lowercase(tabA[j].alamat) > lowercase(tabA[current].alamat);
                    3:  if mode = 1 then
                            q:=tabA[j].jarak < tabA[current].jarak
                        else
                            q:=tabA[j].jarak > tabA[current].jarak;
                end;

                if q then
                    current :=j;
            end;
            tmp := tabA[current];
            tabA[current] := tabA[i];
            tabA[i] := tmp;
        end;

    end;

    procedure deleteSiswa(var B: arraySiswa; noPes: integer);
    var
        i, noPesX: integer;
    begin
        noPesX := getnoPesX(noPes);
        if (noPesX > length(B)-1) or (noPesX < 0) then
            writeln('[x] ID tidak valid')
        else
        begin
            for i:=noPesX to length(B)-2 do
            begin
                B[i] := B[i+1];
            end;
            setLength(B, length(B)-1);
            clrscr;
            writeln('[!] Data Telah Terhapus');
            saveSiswa();
        end;
        readln;
    end;

    procedure showSiswa(var B: arraySiswa; noPesX: integer);
    begin
        writeln('No Peserta  : ', noPesX+1);
        writeln('Nama        : ', B[noPesX].nama);
        writeln('Alamat      : ', B[noPesX].alamat);
        writeln('Jarak       : ', B[noPesX].jarak);
    end;

    procedure drawColContent(text: string; size: integer);
    var
        j:integer;
    begin
        write('|', text);
        for j:=1 to size - length(text) do
                write(' ');
    end;

    procedure tableSiswa(var B: arraySiswa; var maxPage: integer; currentPage: integer; perPage: integer);
    type column = record
        size: integer;
        title: string;
    end;
    var
        col: array of column;
        i, totalwidth: integer;

        i_start, i_stop: integer;
    begin
        maxPage := ceil(length(B) / perPage);
        i_start := perPage * (currentPage - 1);
        i_stop := i_start + perPage - 1;
        if i_stop > length(B) - 1 then
            i_stop := i_stop - (i_stop - length(B)) - 1;

        setLength(col, 8);

        col[0].size  := 13;
        col[0].title := 'Nomor Peserta';

        col[1].size  := 20;
        col[1].title := 'Nama';

        col[2].size  := 10;
        col[2].title := 'Umur';

        col[3].size  := 13;
        col[3].title := 'Jenis Kelamin';

        col[4].size  := 30;
        col[4].title := 'Alamat';

        col[5].size  := 20;
        col[5].title := 'Nama Orang Tua';

        col[6].size  := 8;
        col[6].title := 'Jarak';

        col[7].size  := 20;
        col[7].title := 'Diterima';

        // Draw header
        totalwidth := length(col)+1;
        for i:= 0 to length(col)-1 do
        begin
            totalwidth := totalwidth + col[i].size;
        end;

        for i:=1 to totalwidth do
            write('=');
        writeln();

        for i:= 0 to length(col)-1 do
        begin
            drawColContent(col[i].title, col[i].size);
        end;
        writeln('|');

        for i:=1 to totalwidth do
            write('=');
        writeln();

        // Draw main data
        for i:=i_start to i_stop do
        begin
            drawColContent(inttostr(B[i].noPeserta), col[0].size);
            drawColContent(B[i].nama, col[1].size);
            drawColContent(B[i].umur, col[2].size);
            drawColContent(B[i].jKelamin, col[3].size);
            drawColContent(B[i].alamat, col[4].size);
            drawColContent(B[i].nOrtu, col[5].size);
            drawColContent(inttostr(B[i].jarak), col[6].size);
            if B[i].diterima then
                drawColContent('Diterima', col[7].size)
            else
                drawColContent('Tidak Diterima', col[7].size);

            writeln('|');
        end;

        for i:=1 to totalwidth do
            write('=');
        writeln();
        writeln('Halaman ', currentPage, ' dari ', maxPage);

        writeln();
    end;

    procedure editSiswa(var A: arraySiswa; id: integer);
    var
        noPesX: integer;
        data: siswa;
    begin
        noPesX := getnoPesX(id);
        if (noPesX > length(A) - 1) or (noPesX < 0) then
            writeln('[x] ID tidak valid')
        else
        begin
            clrscr;
            data := A[noPesX];
            writeln('============== EDIT DATA SISWA ===========');
            showSiswa(A, noPesX);
            writeln('================= DATA BARU ==============');
            write('nama           : '); readln(data.nama);
            write('Umur           : '); readln(data.umur);
            write('Jenis Kelamin  : '); readln(data.jKelamin);
            write('Alamat         : '); readln(data.alamat);
            write('Nama Orang Tua : '); readln(data.nOrtu);
            write('Jarak          : '); readln(data.jarak);
            writeln('==========================================');

            if (data.jarak > maxJarak) then
               data.diterima := false
            else
                data.diterima := true;

            A[noPesX] := data;
            writeln('[!] Data Berhasil Di-edit');
            saveSiswa();
        end;
        readln;
    end;

    procedure tampilanDaftar(diterima: boolean);
    var
        p, i: integer;
        cari: string;
        cari_k, urutkan_k, urutkan_m: integer;

        // Pagination Var
        maxPage, currentPage: integer;
        data: arraySiswa;
    begin
        cari := '';
        cari_k := 0;
        currentPage := 1;
        repeat
            clrscr;
            writeln('=============================');
            writeln('======= Daftar Siswa ========');
            if diterima then
                writeln('========  Diterima  =========')
            else
                writeln('=====  Tidak Diterima  ======');
            writeln('=============================');
            writeln();

            if cari <> '' then
                writeln('[!] Menampilkan hasil pencarian ', cari);

            data := getData(dataSiswa, cari, cari_k, diterima);

            tableSiswa(data, maxPage, currentPage, 5);

            writeln('BAGI SISWA YANG TIDAK DITERIMA DALAM DAFTAR TERSEBUT DISARANKAN MENDAFTAR KE SEKOLAH SWASTA');
            readln;

            if currentPage > 1 then
                write('[8]Halaman Sebelumnya ');
            if currentPage < maxPage then
                write('[9]Halaman Selanjutnya ');

            writeln();
            if cari <> '' then
                writeln('[0]Bersihkan Pencarian');

            if isAdmin then
                writeln('[1]Edit [2]Hapus [3]Cari [4]Urutkan [5]Kembali')
            else
                writeln('[3]Cari [4]Urutkan [5]Kembali');

            write('Pilihan > ');
            readln(p);
            case p of
                0:
                    begin
                        cari := '';
                        cari_k := 0;
                    end;
                1:
                    begin
                        if isAdmin then
                        begin
                            write('[Edit] Masukkan ID: ');
                            readln(i);
                            editSiswa(dataSiswa, i);
                        end;
                    end;
                2:
                    begin
                        if isAdmin then
                        begin
                            write('[Hapus] Masukkan ID: ');
                            readln(i);
                            deleteSiswa(dataSiswa, i);
                        end;
                    end;
                3:
                    begin
                        write('[Cari] Cari Berdasarkan [1]Nama [2]Alamat [3]Jarak: ');
                        readln(cari_k);
                        write('[Cari] Kata Kunci: ');
                        readln(cari);
                    end;
                4:
                    begin
                        write('[Urutkan] Urutkan Berdasarkan [1]Nama [2]Alamat [3]Jarak: ');
                        readln(urutkan_k);
                        write('[Urutkan] Mode Pengurutan [1]Ascending [2]Descending: ');
                        readln(urutkan_m);
                        sort(dataSiswa, urutkan_k, urutkan_m);
                    end;

                8: if currentPage > 1 then
                    currentPage := currentPage - 1;
                9: if currentPage < maxPage then
                    currentPage := currentPage + 1;
            end;
        until(p = 5);
    end;

    procedure inputData();
    var
        i, n, l: integer;
        s: siswa;
    begin
        l := length(dataSiswa);
        repeat
            clrscr;
            writeln('== Pendaftaran Siswa ==');
            writeln('Kuota Tersisa: ', maxSiswa - count(true));
            write('Jumlah Input : ');
            readln(n);
            if n > (maxSiswa - l) then
            begin
                writeln('[x] Jumlah input melebihi quota');
                readln;
            end;
        until n <= (maxSiswa - l);

        writeln('===========================');
        for i:=1 to n do
        begin
            l := length(dataSiswa);
            writeln('Input-', i);
            if l > 0 then
                s.noPeserta := dataSiswa[l-1].noPeserta + 1
            else
                s.noPeserta := 1;

            write('Nama           : '); readln(s.nama);
            write('Umur           : '); readln(s.umur);
            write('Jenis Kelamin  : '); readln(s.jKelamin);
            write('Alamat         : '); readln(s.alamat);
            write('Nama Orang Tua : '); readln(s.nOrtu);
            write('Jarak (KM)     : '); readln(s.jarak);
            if ((s.jarak > maxJarak) or (count(true) = maxSiswa)) then
                s.diterima := false
            else
                s.diterima := true;

            setLength(dataSiswa, l+1);
            dataSiswa[l] := s;
            writeln('=============================');
        end;
        saveSiswa();
    end;

    procedure hasilPendaftaran();
    var
        p: integer;
    begin
        repeat
            clrscr;
            writeln('===========================');
            writeln('=        Lihat Data       =');
            writeln('===========================');
            writeln('= 1 -> Diterima           =');
            writeln('= 2 -> Tidak Diterima     =');
            writeln('= 3 -> Kembali            =');
            writeln('===========================');
            write('Pilihan > ');
            readln(p);
            case p of
                1: tampilanDaftar(true);
                2: tampilanDaftar(false);
            end;
        until (p = 3);
    end;

    procedure peraturan();
    var
        s: string;
    begin
        clrscr;
        writeln('===============================================================================');
        writeln('=       Selamat Datang di Halaman Peraturan dan Persyaratan Pendaftaran       =');
        writeln('===============================================================================');
        writeln('= 1. Isi data yang sudah disediakan                                           =');
        writeln('= 2. Siswa dapat diterima bila jarak dari rumah ke sekolah kurang dari        =');
        writeln('=    20 kilometer atau sama dengan 20 kilometer, dan bisa masuk selama kuota  =');
        writeln('=    75 orang belum terpenuhi                                                 =');
        writeln('= 3. Jika siswa yang jarak kesekolahnya lebih dari 20 kilometer atau kuota    =');
        writeln('=    sudah lebih dari 75 orang (penuh), maka disarankan anak tersebut masuk   =');
        writeln('=    SD Swasta                                                                =');
        writeln('===============================================================================');
        readln;
    end;

    procedure gantiPassword();
    var
        s: string;
    begin
        clrscr;
        write('Masukkan Password Baru: ');
        readln(s);
        setAdminPassword(s);
        writeln('Password Berhasil Diganti!');
        readln;
    end;

    procedure menuUtama();
    var
        p: integer;
        c: char;
    begin
        repeat
            clrscr;
            writeln('=================================================================');
            writeln('=                         SELAMAT DATANG                        =');
            writeln('=                               DI                              =');
            writeln('=                  PENDAFTARAN PESERTA DIDIK BARU               =');
            writeln('=                    SEKOLAH DASAR EMERALD CITY                 =');
            writeln('=================================================================');
            writeln('= 1 -> Peraturan                                                =');
            writeln('= 2 -> Input Data                                               =');
            writeln('= 3 -> Lihat Hasil Pendaftaran                                  =');
            writeln('= 4 -> Ganti Password                                           =');
            writeln('= 5 -> Kembali                                                  =');
            writeln('=================================================================');
            write('Pilihan > ');
            readln(p);
            case p of
            1: peraturan();
            2: inputData();
            3: hasilPendaftaran();
            4: gantiPassword();
            end;
        until(p = 5);
    end;


    procedure tampilanLogin();
    var
        pass, s: string;
    begin
        clrscr;
        s:=getAdminPassword();
        write('Masukkan Password: ');
        readln(pass);
        if pass = s then
        begin
            isAdmin := true;
            menuUtama();
        end
        else
        begin
            writeln('Password Salah!');
            readln;
        end;
    end;

    procedure halamanLogin();
    var
        p: integer;
        c: char;
    begin
        repeat
            repeat
                isAdmin := false;
                clrscr;
                writeln('=================================================================================================');
                writeln('|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||');
                writeln('|||||||||||||     //             ///////        ////////             //     //      //     ||||||');
                writeln('||||||||||||     //           //       //    //        //           //     ///     //     |||||||');
                writeln('|||||||||||     //           //       //    //        //           //     // //   //     ||||||||');
                writeln('||||||||||     //           //       //    //                     //     //  //  //     |||||||||');
                writeln('|||||||||     //           //       //    //    //////           //     //   // //     ||||||||||');
                writeln('||||||||     //           //       //    //        //           //     //    ////     |||||||||||');
                writeln('|||||||     //           //       //    //        //           //     //     ///     ||||||||||||');
                writeln('||||||     ///////////   ////////         ///////      //     //     //      //     |||||||||||||');
                writeln('|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||');
                writeln('=================================================================================================');
                writeln('= 1 -> Admin                                                                                    =');
                writeln('= 2 -> Pengunjung                                                                               =');
                writeln('= 3 -> Keluar                                                                                   =');
                writeln('=================================================================================================');
                write('Pilihan > ');
                readln(p);
                case p of
                    1: tampilanLogin();
                    2: hasilPendaftaran();
                end;
            until (p = 3);
            write('Anda yakin ingin keluar? (O/X): ');
            readln(c);
        until(c = 'o') or (c = 'O');
        writeln('Sampai Jumpa!');
    end;

begin
    init();
    halamanLogin();
end.
