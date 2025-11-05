bits 16    

org 0 

start: jmp main



bpbOEM        db	"wtOS----"	;		
bpbBytesPerSector    dw	512            
bpbSectorsPerCluster db	1               
bpbReservedSectors  dw	1               
bpbNumberOfFATs      db	2               
bpbRootEntries       dw	224             
bpbTotalSectors      dw	2880            
bpbMedia             db	0xf0            
bpbSectorsPerFAT     dw	9               
bpbSectorsPerTrack   dw	18              
bpbHeadsPerCylinder  dw	2              
bpbTotalSectorsBig   dd	0               
bsDriveNumber        db	0               
bsUnused             db	0               
bsExtendedBootSignature db	0x29    
bsSerialNumber       dd	0xa0a1a2a3     
bsVolumeLabel        db	"wtOS Volume"   
bsFileSystem         db	"FAT12   "     

msg	db	"***wtOS***", 0		



Print:
        lodsb              
        or al, al          
        jz  PrintDone      
        mov ah, 0x0e       
        int 0x10
        jmp Print    

    PrintDone:
        ret



ReadSectors:
     .MAIN:
          mov     di, 0x0005                        
     .SECTORLOOP:
          push    ax
          push    bx
          push    cx
          call    LBACHS                             
          mov     ah, 0x02                            
          mov     al, 0x01                            
          mov     ch, BYTE [absoluteTrack]            
          mov     cl, BYTE [absoluteSector]           
          mov     dh, BYTE [absoluteHead]             
          mov     dl, BYTE [bsDriveNumber]            
          int     0x13                               
          jnc     .SUCCESS                            
          xor     ax, ax                              
          int     0x13                                
          dec     di                                  
          pop     cx
          pop     bx
          pop     ax
          jnz     .SECTORLOOP                         
          int     0x18
     .SUCCESS:
          mov     si, msgProgress
          call    Print
          pop     cx
          pop     bx
          pop     ax
          add     bx, WORD [bpbBytesPerSector]        
          inc     ax                                  
          loop    .MAIN                               
          ret


ClusterLBA:
          sub     ax, 0x0002                          
          xor     cx, cx
          mov     cl, BYTE [bpbSectorsPerCluster]     
          mul     cx
          add     ax, WORD [datasector]              
          ret
     


LBACHS:
          xor     dx, dx                              
          div     WORD [bpbSectorsPerTrack]          
          inc     dl                                 
          mov     BYTE [absoluteSector], dl
          xor     dx, dx                              
          div     WORD [bpbHeadsPerCylinder]         
          mov     BYTE [absoluteHead], dl
          mov     BYTE [absoluteTrack], al
          ret



main:


          cli						
          mov     ax, 0x07C0		
          mov     ds, ax
          mov     es, ax
          mov     fs, ax
          mov     gs, ax


     
          mov     ax, 0x0000		
          mov     ss, ax
          mov     sp, 0xFFFF
          sti						


          mov     si, msgLoading
          call    Print
          


     LOAD_ROOT:
     
     
          xor     cx, cx
          xor     dx, dx
          mov     ax, 0x0020                           
          mul     WORD [bpbRootEntries]               
          div     WORD [bpbBytesPerSector]            
          xchg    ax, cx

     
          mov     al, BYTE [bpbNumberOfFATs]           
          mul     WORD [bpbSectorsPerFAT]               
          add     ax, WORD [bpbReservedSectors]         
          mov     WORD [datasector], ax                 
          add     WORD [datasector], cx
          

     
          mov     bx, 0x0200                            
          call    ReadSectors


          mov     cx, WORD [bpbRootEntries]             
          mov     di, 0x0200                            
          push    cx
          mov     cx, 0x000B                          
          mov     si, ImageName                        
          push    di
     	  rep     cmpsb                                
          pop     di
          je      LOAD_FAT
          pop     cx
          add     di, 0x0020                            
          loop    .LOOP
          jmp     FAILURE

     LOAD_FAT:
     
    
     
          mov     si, msgCRLF
          call    Print
          mov     dx, WORD [di + 0x001A]
          mov     WORD [cluster], dx                 
          

     
          xor     ax, ax
          mov     al, BYTE [bpbNumberOfFATs]          
          mul     WORD [bpbSectorsPerFAT]            
          mov     cx, ax



          mov     ax, WORD [bpbReservedSectors]       
          
    

          mov     bx, 0x0200                        
          call    ReadSectors


     
          mov     si, msgCRLF
          call    Print
          mov     ax, 0x0050
          mov     es, ax                             
          mov     bx, 0x0000                          
          push    bx


     LOAD_IMAGE:
     
          mov     ax, WORD [cluster]                  
          pop     bx                                 
          call    ClusterLBA                          
          xor     cx, cx
          mov     cl, BYTE [bpbSectorsPerCluster]    
          call    ReadSectors
          push    bx
          

     
          mov     ax, WORD [cluster]                  
          mov     cx, ax                             
          mov     dx, ax                             
          shr     dx, 0x0001                          
          add     cx, dx                             
          mov     bx, 0x0200                         
          add     bx, cx                             
          mov     dx, WORD [bx]                     
          test    ax, 0x0001
          jnz     .ODD_CLUSTER
          
     .EVEN_CLUSTER:
     
          and     dx, 0000111111111111b              
         jmp     .DONE
         
     .ODD_CLUSTER:
     
          shr     dx, 0x0004                          
          
     .DONE:
     
          mov     WORD [cluster], dx                 
          cmp     dx, 0x0FF0                          
          jb      LOAD_IMAGE
          
     DONE:
     
          mov     si, msgCRLF
          call    Print
          push    WORD 0x0050
          push    WORD 0x0000
          retf
          
     FAILURE:
     
          mov     si, msgFailure
          call    Print
          mov     ah, 0x00
          int     0x16                               
          int     0x19                               
     absoluteSector db 0x00
     absoluteHead   db 0x00
     absoluteTrack  db 0x00
     datasector  dw 0x0000
     cluster     dw 0x0000
     ImageName   db "WT      SYS"
     msgLoading  db 0x0D, 0x0A, "Loading Boot Image ", 0x0D, 0x0A, 0x00
     msgCRLF     db 0x0D, 0x0A, 0x00
     msgProgress db ".", 0x00
     msgFailure  db 0x0D, 0x0A, "ERROR : Press Any Key to Reboot", 0x0A, 0x00
     
     times 510-($-$$) DB 0
     dw 0xAA55
