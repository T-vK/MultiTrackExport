;nyquist plug-in
;version 4
;type process
;name "MultiTrackExport"
;debugbutton false
;action "Running MultiTrackExport..."
;author "T-vK"
;release 1.0.0
;copyright "Public Domain"

;; multi-track-export.ny by T-vK, Feburary 2023

;; For information about writing and modifying Nyquist plug-ins:
;; https://wiki.audacityteam.org/wiki/Nyquist_Plug-ins_Reference

define function inttostring(n, zeropadding: 0)
    begin
        if n = 0 then return "0";
        if zeropadding = nil then set zeropadding = 0;
        set result = ""
        loop
            while n > 0
            ; Get last digit
            set digit = n % 10
            set result = strcat(string(digit + 48), result)
            ; Remove last digit
            set n = round(n / 10 - 0.5)
        end
        set digitcount = length(result)
        if digitcount < zeropadding then
            begin
                loop
                    repeat zeropadding - digitcount
                    set result = strcat("0", result)
                end
            end
        return result
    end

define function searchprojectfile(projectname, prefcategory)
    begin
        if prefcategory = "RecentFiles" then 
            begin
                set keyprefix = "file"
                set padding = 2
            end
        else
            if prefcategory = "ActiveProjects" then 
                begin
                    set keyprefix = ""
                    set padding = 0
                end
        set sanitycheckpassed = 0
        set fullfilepath = "/"
        loop
            for fileindex from 1 below 1000 by 1
                until sanitycheckpassed = 1 | fullfilepath = ""
                begin
                    ; Convert the index to a string and append it to /RecentFiles/file0n
                    set prefname = strcat("/", prefcategory, "/", keyprefix, inttostring(fileindex, zeropadding: padding))
                    
                    ; Get the path to the current project file (not very reliable)
                    set fullfilepath = first(AUD-DO(strcat("GetPreference: Name=", prefname)))
                    
                    ; Check if the project file path was found and is correct
                    if projectname != "" then
                        begin
                            set pos = string-search(projectname, fullfilepath)
                            if pos != nil then
                                begin
                                    set expectedpos = length(fullfilepath) - length(projectname) - length(".aup3")
                                    if pos = expectedpos then
                                        begin
                                            set sanitycheckpassed = 1
                                        end
                                end
                        end
                end
            end
        return fullfilepath
    end


;Get project name
set projectname = get(quote(*project*), quote(name))

set fullfilepath = searchprojectfile(projectname, "ActiveProjects")
if fullfilepath = "" then set fullfilepath = searchprojectfile(projectname, "RecentFiles");

; Set the default export directory to Audacity's temp folder
set dirpath = get(quote(*system-dir*), quote(temp))

; If the correct project file path was found, use its directory instead of the temp dir
if sanitycheckpassed = 1 then
    begin
        ; Extract the directory path by cutting off the file name after the last slash:
        loop
            for i from 0 below length(fullfilepath) - 1 by 1
            if char-int(char(fullfilepath, i)) = 47 then set lastslashindex = i;
        end
        set dirpath = subseq(fullfilepath, 0, lastslashindex)
    end

; Get the track name
set trackname = get(quote(*track*), quote(name))

; Generate the full path for the wav file we will be exporting with s-save
set filepath = strcat(dirpath, "/", trackname, ".wav")

; Export track(s) as wav to the project directory using {TRACKNAME}.wav as the file name
exec s-save(*track*, ny:all, filepath, format: snd-head-Wave, mode: snd-mode-pcm, bits: 16)

;return filepath
return
""