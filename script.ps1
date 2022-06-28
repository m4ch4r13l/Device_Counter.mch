#Script para detectar dispositivos y contar las veces que se ha conectado

#Escondiendo ventana del PowerShell
PowerShell.exe -windowstyle hidden{

#declarando las variables
$conect = 0
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
            if($conect -eq 0)
            {
                #Ejecutando la funcion "Contador"
                Counter
                Write-Output "Device Conect $LINE"

                #Cambiando el valor de $conect 
                $global:conect  = 1
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
}

function Counter
{
    [int]$counter = 0

    $counter = Get-Content "counter.txt"

    $counterSuma = $counter + 1

    if ($counterSuma -ge 2)
    {
        $msgResp = [System.Windows.MessageBox]::Show('El cable a llegado a su limite de usos, ¿Desea remplazarlo?', 'ADVERTENCIA', 'YesNo','warning')
        
        switch ($msgResp)
        {
            'Yes' 
            {
    	        Set-Content -Path counter.txt -Value 0
            }
            'No' 
            {
    	        Set-Content -Path counter.txt -Value $counterSuma
            }
        }
    }
    else
    {
        Set-Content -Path counter.txt -Value $counterSuma
    }
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
            $conect = 1
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

