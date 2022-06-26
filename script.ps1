#Script para detectar dispositivos y contar las veces que se ha conectado

#Escondiendo ventana del PowerShell
PowerShell.exe -windowstyle hidden{

Register-WmiEvent -Class Win32_DeviceChangeEvent -SourceIdentifier DeviceChangeEvent
write-host (get-date -format s) " Beginning script..."

#declarando la variable Conect para controlar cuando el dispositivo este conectado
$conect = 0

#Creando lista de dispositivos conectados
Start-Process "id.bat"

do{

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
    if ($eventType -eq 2)
    {
        write-host (get-date -format s) " Starting task in 3 seconds..."
        start-sleep -Milliseconds 1
        
        #Creando lista de dispositivos conectados
        Start-Process "id.bat"

        Start-Sleep -Seconds 3

        #Recorriendo el .txt para comprobar si el dispositivo deseado esta conectado en el pc
        $FILE = Get-Content "ids.txt"
        foreach ($LINE in $FILE) 
        {
            #Comprobando el nombre del dispositivo deseado
            if($LINE -eq "    Name: Magic Leap 21" -or $LINE -eq "    Name: Demophon")
            {
                #Comprobando si el dispositivo ha sido detectado anteriormente
                if($conect -eq 0)
                {
                    #Ejecutando el archivo "cont.bat" para realizar el contador
                    start-process "cont.bat"
                    Write-Output "Device Conect $LINE"

                    #Cambiando el valor de $conect 
                    $conect = 1
                }
                else
                {
                    Write-Output "The device is already connected"
                }
            }
        }
        if ($conect -eq 0)
        {
            Write-Output "Device is not connected"
        }

    }#Condicional al detectar el caso 3
    elseif ($eventType -eq 3) 
    {
        Start-Process "id.bat"
        Start-Sleep -Seconds 3
        $FILE = Get-Content "ids.txt"
        foreach ($LINE in $FILE) 
        {
            if($LINE -eq "    Name: Mouse compatible con HID")
            {
                Write-Output "Device is still connected"
                $conect = 1
                Break
            }
            else
            {
                $conect = 0
            }
        }
        if ($conect -eq 0)
        {
            Write-Output "The device has been disconnected"
        }
    }

    Remove-Event -SourceIdentifier DeviceChangeEvent

    }

    while (1-eq1) #Loop until next event

    Unregister-Event -SourceIdentifier DeviceChangeEvent
}
