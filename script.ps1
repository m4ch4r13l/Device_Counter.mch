#Script para detectar dispositivos y contar las veces que se ha conectado

#Escondiendo ventana del PowerShell
#PowerShell.exe -windowstyle hidden{

#declarando las variables
$connect = 0
$inirialConnect = 0
Add-Type -AssemblyName PresentationFramework

function connect
{
    #Recorriendo el .txt para comprobar si el dispositivo deseado esta conectado en el pc
    $FILE = Get-Content "ids.txt"
    foreach ($LINE in $FILE) 
    {
        #Comprobando el nombre del dispositivo deseado
        if($LINE -eq "    Name: Mouse compatible con HID")
        {
            #Comprobando si el dispositivo ha sido detectado anteriormente
            if($global:connect -eq 0)
            {
                #Ejecutando la funcion "Contador"
                CounterWTBT
                Write-Output "Device Conect $LINE"

                #Cambiando el valor de $conect 
                $global:connect  = 1
            }
            else
            {
                Write-Output "The device is already connected"
            }
        }
    }
    if ($global:connect -eq 0)
    {
        Write-Output "Device is not connected"
    }
}

function CounterWTBT
{

    $counterResp = Get-Content "Counter WTBT.txt"
    Set-Content -Path "Counter WTBT RESP.txt" -Value $counterResp

    $counterFlexTXT  = Get-Content "Counter WTBT.txt" | Select -First 2
    $counterTypeCTXT = Get-Content "Counter WTBT.txt" | Select -First 3
    $counterCableTXT = Get-Content "Counter WTBT.txt" | Select -First 4

    $counterFlexTXT.Split(" ") | ForEach {
        $counterFlex = $_
     }
     $counterTypeCTXT.Split(" ") | ForEach {
        $counterTypeC = $_
     }
     $counterCableTXT.Split(" ") | ForEach {
        $counterCable = $_
     }
    
    $counterSumaFlex   = [int]$counterFlex + 1
    $counterSumaTypeC  = [int]$counterTypeC + 1
    $counterSumaCable  = [int]$counterCable + 1

    Remove-Item -Path "Counter WTBT.txt"
    Add-Content -Path "Counter WTBT.txt" -Value "***COUNTER WTBT***"

    #cable Flex
    if ($counterSumaFlex -ge 5)
    {
        $msgResp = [System.Windows.MessageBox]::Show('El cable Flex a llegado a su limite de usos, ¿Desea remplazarlo?', 'ADVERTENCIA', 'YesNo','warning')
        
        switch ($msgResp)
        {
            'Yes' 
            {
                $counterFlexTXT = "Counter Flex:   0"
    	        Add-Content -Path "Counter WTBT.txt" -Value $counterFlexTXT
            }
            'No' 
            {
    	        $counterFlexTXT = "Counter Flex:   $counterSumaFlex"
    	        Add-Content -Path "Counter WTBT.txt" -Value $counterFlexTXT
            }
        }
    }
    else
    {
        $counterFlexTXT = "Counter Flex:   $counterSumaFlex"
        Add-Content -Path "Counter WTBT.txt" -Value $counterFlexTXT
    }

    #Cable Tipo C
    if ($counterSumaTypeC -ge 7)
    {
        $msgResp = [System.Windows.MessageBox]::Show('El cable tipo C a llegado a su limite de usos, ¿Desea remplazarlo?', 'ADVERTENCIA', 'YesNo','warning')
        
        switch ($msgResp)
        {
            'Yes' 
            {
    	        $counterTypeCTXT = "Counter Type C: 0"
    	        Add-Content -Path "Counter WTBT.txt" -Value $counterTypeCTXT
            }
            'No' 
            {
    	        $counterTypeCTXT = "Counter Type C: $counterSumaTypeC"
    	        Add-Content -Path "Counter WTBT.txt" -Value $counterTypeCTXT
            }
        }
    }
    else
    {
        $counterTypeCTXT = "Counter Type C: $counterSumaTypeC"
    	Add-Content -Path "Counter WTBT.txt" -Value $counterTypeCTXT
    }

    #Cable 
    if ($counterSumaCable -ge 3)
    {
        $msgResp = [System.Windows.MessageBox]::Show('El cable a llegado a su limite de usos, ¿Desea remplazarlo?', 'ADVERTENCIA', 'YesNo','warning')
        
        switch ($msgResp)
        {
            'Yes' 
            {
    	        $counterCableTXT = "Counter Cable:  0"
    	        Add-Content -Path "Counter WTBT.txt" -Value $counterCableTXT
            }
            'No' 
            {
    	        $counterCableTXT = "Counter Cable:  $counterSumaCable"
    	        Add-Content -Path "Counter WTBT.txt" -Value $counterCableTXT
            }
        }
    }
    else
    {
        $counterCableTXT = "Counter Cable:  $counterSumaCable"
    	Add-Content -Path "Counter WTBT.txt" -Value $counterCableTXT
    }

    $counterResp = Get-Content "Counter WTBT.txt"
    Set-Content -Path "Counter WTBT RESP.txt" -Value $counterResp
}

Register-WmiEvent -Class Win32_DeviceChangeEvent -SourceIdentifier DeviceChangeEvent
write-host (get-date -format s) " Beginning script..."

#Creando lista de dispositivos conectados
cmd.exe /c devcon hwids * > ids.txt

do
{

    #declarando los eventos
    $newEvent = Wait-Event -SourceIdentifier DeviceChangeEvent
    $eventType = $newEvent.SourceEventArgs.NewEvent.EventType
    $eventTypeName = switch($eventType)
    {
        #definiendo los casos de los eventos
        1 {"Configuration changed"}
        2 {"Device arrival"}
        3 {"Device removal"}
        4 {"docking"}
    }

    write-host (get-date -format s) " Event detected = " $eventTypeName

    #Condicional al detectar el evento 2
    if($eventType -eq 1)
    {
    
        if($inirialConnect -eq 0)
        {
            #Creando lista de dispositivos conectados
            cmd.exe /c devcon hwids * > ids.txt
            Start-Sleep -Seconds 1
            connect
            $connect = 1
            $inirialConnect = 1
        }
    }
    elseif ($eventType -eq 2)
    {
        #Creando lista de dispositivos conectados
        cmd.exe /c devcon hwids * > ids.txt
        Start-Sleep -Seconds 1
        connect
    }
    #Condicional al detectar el caso 3
    elseif ($eventType -eq 3) 
    {
        cmd.exe /c devcon hwids * > ids.txt
        Start-Sleep -Seconds 1
        $FILE = Get-Content "ids.txt"
        foreach ($LINE in $FILE) 
        {
            if($LINE -eq "    Name: Mouse compatible con HID")
            {
                Write-Output "Device is still connected"
                $connect = 1
                Break
            }
            else
            {
                $connect = 0
            }
        }
        if ($connect -eq 0)
        {
            Write-Output "The device has been disconnected"
        }
    }

    Remove-Event -SourceIdentifier DeviceChangeEvent

    }

    while (1-eq1) #Loop until next event

    Unregister-Event -SourceIdentifier DeviceChangeEvent
#}

