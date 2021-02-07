import idaapi
import time
from os import path,makedirs

while True:
    GetDebuggerEvent(WFNE_SUSP|WFNE_CONT, 60)
    flag = GetRegValue('R0')
    file_buffer = GetRegValue('R1')
    file_size = GetRegValue('R2')
    file_name = GetRegValue('R3')

    if file_size != 0:
        file_content = idaapi.dbg_read_memory(file_buffer, file_size)
        if file_buffer == file_name:
            print "same name to file content"
            fp = open("e:\\xxx\\other_.log","ab+")
            fp.write("-----\n")
            fp.write(file_content)
            fp.close()
            continue
        file_path = ""
        while '\0' != idaapi.dbg_read_memory(file_name, 1):
            file_path += idaapi.dbg_read_memory(file_name, 1)
            file_name += 1
        dir_path,_ = path.split(file_path)
        dir_path = path.join("e:\\xxx\\", dir_path.replace('/','\\'))
        file_dis =  path.join("e:\\xxx\\", file_path.replace('/','\\'))
        print dir_path, file_dis
        #print file_content
        if not path.exists(dir_path):
            makedirs(dir_path)
        fp = open(file_dis,"wb+")
        fp.write(file_content)
        fp.close()
