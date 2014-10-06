clear all;

waitfor(msgbox('The code runs only if the EnergyPlus is in Cdrive with Path "C:\EnergyPlusV8-1-0" . Please rename the RunEplus.bat to RunEplus_bk.bat and copy the RunEplus.bat supplied with this code in the folder. Also avoid placing the idf files in nested folder, as DOS path length is 256 character'));

% EnergyPlus .idf Folder Selection
IdfFolder = uigetdir('Select the EnergyPlus idf folder');
% Weatherfile .epw Folder Selection
WeatherFolder = uigetdir('Select the weatherfile folder');
% EnergyPlus Folder Path
[idfPathname] = IdfFolder;
% Weatherfile Folder Path
[WeatherPathname] = WeatherFolder;

% listing EnergyPlus Folder content and only files with extension *.idf
IdfFiles = dir(fullfile(idfPathname,'\*.idf'));
% listing WeatherFolder directory content
WeatherFiles = dir(WeatherFolder);

% creating list dialog shwoing idf files in the folder selected earlier,
% multiple files selection enabled
IdfFolderStr = {IdfFiles.name};
[s,v] = listdlg('PromptString','Select a file:',...
                'SelectionMode','multiple',...
                'ListString',IdfFolderStr,'ListSize',[500 300]);


if v
    for idx = s
         IdfFileName = IdfFolderStr(idx);
         pattern1 = '.idf';
         replacement1 = '';
         pattern2 = '.epw';
         IdfFileNameExtRm=regexprep(IdfFileName,pattern1,replacement1);
         IdfFileNameExtRmSplt = strsplit(char(IdfFileNameExtRm),'_'); 

 %loop helps in selection of weather file of the same city as idf file, 
 % as it is required to provide the weather for energyplus simulation 

        IndexWeat =find(~[WeatherFiles.isdir]);
 
        k=0;
        b = true;
        while b
            k=k+1;
            WeatherFileName = WeatherFiles(IndexWeat(k)).name;
            WeatherFileNameExtRm=num2str(regexprep(WeatherFileName,pattern2,replacement1)); 
            WeatherFileNameExtRmSplt = strsplit(WeatherFileNameExtRm,'_') ;
            cmp = length(intersect(IdfFileNameExtRmSplt,WeatherFileNameExtRmSplt));
            b =cmp < 4;
        end
           
        IdfFilePath = fullfile(idfPathname,IdfFileName);
        fd1 = fileread(char(IdfFilePath));
    
        if regexp(IdfFileName{:},'Small')>0
            fidsr1 = fopen('replace1.txt', 'r'); % Read-only (creates a file if there is none there)
            pattern3='....CLGSETP_SCH,[\s\S]*HTGSETP_SCH,[\s\S]*(  MinOA_)'; 
            subchunk = regexp(fd1,pattern3,'match');
            imt = subchunk{1};
            fidsw1 = fopen('replace1.txt', 'w');
            fprintf(fidsw1,imt);
            fclose(fidsw1);
            fidsr2 = fopen('replace1.txt','r'); 
            l = 1;
            tline = fgetl(fidsr2);
            A{l} = tline;
            while ischar(tline)
                l = l+1;
                tline = fgetl(fidsr2);
                A{l} = tline;
            end
            fclose(fidsr2);
            prompt1 = {'For: Weekdays and SummerDesignDay,:24:00 to 06:00hrs:','06:00 to 22:00','22:00 to 24:00','For: Saturday Until: 06:00','Until: 18:00' 'Until: 24:00','For: AllOtherDays,Until: 24:00'};      
            dlg_title1 = 'Cooling SETPT-Temperature,Through: 12/31 ';
            num_lines1 = 1;
            def1 = {'26.7','24.0','26.7','26.7','24.0','26.7','26.7'};
            answer1 = inputdlg(prompt1,dlg_title1,num_lines1,def1);
            prompt2 = {'For: Weekdays:24:00 to 06:00hrs:','06:00 to 22:00','22:00 to 24:00','For: Saturday Until: 06:00','Until: 18:00' 'Until: 24:00','For WinterDesignDay,Until: 24:00','For: AllOtherDays,Until: 24:00'};      
            dlg_title2 = 'Heating SETPT-Temperature,Through: 12/31 ';
            num_lines2 = 1;
            def2 = {'15.6','21.0','15.6','15.6','21.0','15.6','21.0','15.6'};
            answer2 = inputdlg(prompt2,dlg_title2,num_lines2,def2);
            A{5} = sprintf('%s',['    Until: 06:00,',num2str(answer1{1}),',       !- Field 3']);
            A{6} = sprintf('%s',['    Until: 22:00,',num2str(answer1{2}),',       !- Field 5']);
            A{7} = sprintf('%s',['    Until: 24:00,',num2str(answer1{3}),',       !- Field 7']);
            A{9} = sprintf('%s',['    Until: 06:00,',num2str(answer1{4}),',       !- Field 10']);
            A{10} = sprintf('%s',['    Until: 18:00,',num2str(answer1{5}),',       !- Field 12']);
            A{11} = sprintf('%s',['    Until: 24:00,',num2str(answer1{6}),',       !- Field 14']);
            A{13} = sprintf('%s',['    Until: 24:00,',num2str(answer1{7}),';       !- Field 17']);
            A{20} = sprintf('%s',['    Until: 06:00,',num2str(answer2{1}),',       !- Field 3']);
            A{21} = sprintf('%s',['    Until: 22:00,',num2str(answer2{2}),',       !- Field 5']);
            A{22} = sprintf('%s',['    Until: 24:00,',num2str(answer2{3}),',       !- Field 7']);
            A{24} = sprintf('%s',['    Until: 06:00,',num2str(answer2{4}),',       !- Field 10']);
            A{25} = sprintf('%s',['    Until: 18:00,',num2str(answer2{5}),',       !- Field 12']);
            A{26} = sprintf('%s',['    Until: 24:00,',num2str(answer2{6}),',       !- Field 14']);
            A{28} = sprintf('%s',['    Until: 24:00,',num2str(answer2{7}),',       !- Field 17']);
            A{30} = sprintf('%s',['    Until: 24:00,',num2str(answer2{8}),';       !- Field 20']);
           
            fidsw2 = fopen('replace1.txt','w');
            for l = 1:numel(A);
                if A{l+1} == -1
                    fprintf(fidsw2,'%s', A{l});
                    break
                else
                fprintf(fidsw2,'%s\r\n', A{l});
                end
            end
            fclose(fidsw2);       
            pattern3='....CLGSETP_SCH,[\s\S]*HTGSETP_SCH,[\s\S]*(  MinOA_)' ;
            replacement3 = fileread('replace1.txt');
            replacement4=cellstr(replacement3);
            Idfnew=regexprep(fd1,pattern3,replacement4);
            fidsw3 = fopen((char(IdfFilePath)),'w');
            fwrite(fidsw3,Idfnew);
            fclose(fidsw3);
                                                                             
        elseif (regexp(IdfFileName{:},'Medium'))>0
            fidmr1 = fopen('replace2.txt', 'r'); % Read-only (creates a file if there is none there)
            pattern3='....CLGSETP_SCH,[\s\S]*HTGSETP_SCH,[\s\S]*(  MinOA_)' ;
            subchunk = regexp(fd1,pattern3,'match');
            imt = subchunk{1};
            fidmw1 = fopen('replace2.txt', 'w'); % 
            fprintf(fidmw1,imt);
            fclose(fidmw1);
            fidmr2 = fopen('replace2.txt','r') ;
            m = 1;
            tline = fgetl(fidmr2);
            B{m} = tline;
            while ischar(tline)
                m = m+1;
                tline = fgetl(fidmr2);
                B{m} = tline;
            end
            fclose(fidmr2);
            prompt1 = {'For: Weekdays and SummerDesignDay,:24:00 to 06:00hrs:','06:00 to 22:00','22:00 to 24:00','For: Saturday Until: 06:00','Until: 18:00' 'Until: 24:00','For WinterDesignDay,Until: 24:00','For: AllOtherDays,Until: 24:00'};      
            dlg_title1 = 'Cooling SETPT-Temperature,Through: 12/31 ';
            num_lines1 = 1;
            def1 = {'26.7','24.0','26.7','26.7','24.0','26.7','26.7','26.7'};
            answer1 = inputdlg(prompt1,dlg_title1,num_lines1,def1);
            prompt2 = {'For: Weekdays:24:00 to 06:00hrs:','06:00 to 22:00','22:00 to 24:00','For SummerDesignDay,Until: 24:00','For: Saturday Until: 06:00','Until: 18:00' 'Until: 24:00','For WinterDesignDay,Until: 24:00','For: AllOtherDays,Until: 24:00'};      
            dlg_title2 = 'Heating SETPT-Temperature,Through: 12/31 ';
            num_lines2 = 1;
            def2 = {'15.6','21.0','15.6','15.6','15.6','21.0','15.6','21.0','15.6'};
            answer2 = inputdlg(prompt2,dlg_title2,num_lines2,def2);
            B{5} = sprintf('%s',['    Until: 06:00,',num2str(answer1{1}),',       !- Field 3']);
            B{6} = sprintf('%s',['    Until: 22:00,',num2str(answer1{2}),',       !- Field 5']);
            B{7} = sprintf('%s',['    Until: 24:00,',num2str(answer1{3}),',       !- Field 7']);
            B{9} = sprintf('%s',['    Until: 06:00,',num2str(answer1{4}),',       !- Field 10']);
            B{10} = sprintf('%s',['    Until: 18:00,',num2str(answer1{5}),',       !- Field 12']);
            B{11} = sprintf('%s',['    Until: 24:00,',num2str(answer1{6}),',       !- Field 14']);
            B{13} = sprintf('%s',['    Until: 24:00,',num2str(answer1{7}),',       !- Field 17']);
            B{15} = sprintf('%s',['    Until: 24:00,',num2str(answer1{8}),';       !- Field 20']);
            B{22} = sprintf('%s',['    Until: 06:00,',num2str(answer2{1}),',       !- Field 3']);
            B{23} = sprintf('%s',['    Until: 22:00,',num2str(answer2{2}),',       !- Field 5']);
            B{24} = sprintf('%s',['    Until: 24:00,',num2str(answer2{3}),',       !- Field 7']);
            B{26} = sprintf('%s',['    Until: 24:00,',num2str(answer2{4}),',       !- Field 10']);
            B{28} = sprintf('%s',['    Until: 06:00,',num2str(answer2{5}),',       !- Field 13']);
            B{29} = sprintf('%s',['    Until: 18:00,',num2str(answer2{6}),',       !- Field 15']);
            B{30} = sprintf('%s',['    Until: 24:00,',num2str(answer2{7}),',       !- Field 17']);
            B{32} = sprintf('%s',['    Until: 24:00,',num2str(answer2{8}),',       !- Field 20']);
            B{34} = sprintf('%s',['    Until: 24:00,',num2str(answer2{9}),';       !- Field 23']);
            fidmw2 = fopen('replace2.txt','w');
            for m = 1:numel(B)
                if B{m+1} == -1
                    fprintf(fidmw2,'%s', B{m});
                    break
                else
                fprintf(fidmw2,'%s\r\n', B{m});
                end
            end
            fclose(fidmw2);       
            pattern3='....CLGSETP_SCH,[\s\S]*HTGSETP_SCH,[\s\S]*(  MinOA_)' ;
            replacement3 = fileread('replace2.txt');
            replacement4=cellstr(replacement3);
            Idfnew=regexprep(fd1,pattern3,replacement4);
            fidmw3 = fopen((char(IdfFilePath)),'w');
            fwrite(fidmw3,Idfnew);
            fclose(fidmw3);          
            
            
        else 
       
            fidsr1 = fopen('replace3.txt', 'r'); % Read-only (creates a file if there is none there)
            pattern3='....CLGSETP_SCH,[\s\S]*HTGSETP_SCH,[\s\S]*(Seasonal-Reset-Supply-Air-Temp-Sch,  !- Name)' ;
            subchunk = regexp(fd1,pattern3,'match');
            imt = subchunk{1};
            fidsw1 = fopen('replace3.txt', 'w'); % 
            fprintf(fidsw1,imt);
            fclose(fidsw1);
            fidsr2 = fopen('replace3.txt','r') ;
            n = 1;
            tline = fgetl(fidsr2);
            C{n} = tline;
            while ischar(tline)
                n = n+1;
                tline = fgetl(fidsr2);
                C{n} = tline;
            end
            fclose(fidsr2);
            prompt1 = {'For: Weekdays and SummerDesignDay,:24:00 to 06:00hrs:','06:00 to 22:00','22:00 to 24:00','For: Saturday Until: 06:00','Until: 18:00' 'Until: 24:00','For WinterDesignDay,Until: 24:00','For: AllOtherDays,Until: 24:00'};      
            dlg_title1 = 'Cooling SETPT-Temperature,Through: 12/31 ';
            num_lines1 = 1;
            def1 = {'26.7','24.0','26.7','26.7','24.0','26.7','26.7','26.7'};
            answer1 = inputdlg(prompt1,dlg_title1,num_lines1,def1);
            prompt2 = {'For: Weekdays:24:00 to 06:00hrs:','06:00 to 22:00','22:00 to 24:00','For SummerDesignDay,Until: 24:00','For: Saturday Until: 06:00','Until: 18:00' 'Until: 24:00','For WinterDesignDay,Until: 24:00','For: AllOtherDays,Until: 24:00'};      
            dlg_title2 = 'Heating SETPT-Temperature,Through: 12/31 ';
            num_lines2 = 1;
            def2 = {'15.6','21.0','15.6','15.6','15.6','21.0','15.6','21.0','15.6'};
            answer2 = inputdlg(prompt2,dlg_title2,num_lines2,def2);
            C{5} = sprintf('%s',['    Until: 06:00,',num2str(answer1{1}),',       !- Field 3']);
            C{6} = sprintf('%s',['    Until: 22:00,',num2str(answer1{2}),',       !- Field 5']);
            C{7} = sprintf('%s',['    Until: 24:00,',num2str(answer1{3}),',       !- Field 7']);
            C{7} = sprintf('%s',['    Until: 24:00,',num2str(answer1{3}),',       !- Field 7']);
            C{9} = sprintf('%s',['    Until: 06:00,',num2str(answer1{4}),',       !- Field 10']);
            C{10} = sprintf('%s',['    Until: 18:00,',num2str(answer1{5}),',       !- Field 12']);
            C{11} = sprintf('%s',['    Until: 24:00,',num2str(answer1{6}),',       !- Field 14']);
            C{13} = sprintf('%s',['    Until: 24:00,',num2str(answer1{7}),',       !- Field 17']);
            C{15} = sprintf('%s',['    Until: 24:00,',num2str(answer1{8}),';       !- Field 20']);
            C{22} = sprintf('%s',['    Until: 06:00,',num2str(answer2{1}),',       !- Field 3']);
            C{23} = sprintf('%s',['    Until: 22:00,',num2str(answer2{2}),',       !- Field 5']);
            C{24} = sprintf('%s',['    Until: 24:00,',num2str(answer2{3}),',       !- Field 7']);
            C{26} = sprintf('%s',['    Until: 24:00,',num2str(answer2{4}),',       !- Field 10']);
            C{28} = sprintf('%s',['    Until: 06:00,',num2str(answer2{5}),',       !- Field 13']);
            C{29} = sprintf('%s',['    Until: 18:00,',num2str(answer2{6}),',       !- Field 15']);
            C{30} = sprintf('%s',['    Until: 24:00,',num2str(answer2{7}),',       !- Field 17']);
            C{32} = sprintf('%s',['    Until: 24:00,',num2str(answer2{8}),',       !- Field 20']);
            C{34} = sprintf('%s',['    Until: 24:00,',num2str(answer2{9}),';       !- Field 23']);
            fidsw3 = fopen('replace3.txt','w');
            for n = 1:numel(C)
                if C{n+1} == -1
                    fprintf(fidsw3,'%s', C{n});
                    break
                else
                fprintf(fidsw3,'%s\r\n', C{n});
                end
            end
            fclose(fidsw3);       
            pattern3='....CLGSETP_SCH,[\s\S]*HTGSETP_SCH,[\s\S]*(Seasonal-Reset-Supply-Air-Temp-Sch,  !- Name)' ;
            replacement3 = fileread('replace3.txt');
            replacement4=cellstr(replacement3);
            Idfnew=regexprep(fd1,pattern3,replacement4);
            fidsw4 = fopen((char(IdfFilePath)),'w');
            fwrite(fidsw4,Idfnew);
            fclose(fidsw4);
      
        end
    IdfFilePathEplus = fullfile(idfPathname,IdfFileNameExtRm);
    WeatherFilePathEplus =fullfile(WeatherPathname,WeatherFileNameExtRm);
    stri = ['C:\EnergyPlusV8-1-0\RunEPlus '  sprintf('%s',IdfFilePathEplus{:}) ' ' sprintf('%s',WeatherFilePathEplus)]  ;
    dos(stri);    
    end
end



