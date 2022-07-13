<#
.SYNOPSIS
    Simula una papelera de reciclaje.
.DESCRIPTION
    Este script emula una papelera de reciclaje con la opcion de recuperar los archivos con las siguientes opciones:
    -listar: lista todos los archivos que contiene la papelera de reciclaje, informando el nombre y su ubicación original.
    -recuperar [archivo]: recupera el archivo pasado por parámetro a su ubicación original.
    -vaciar: Vacía la papelera de reciclaje (eliminar definitivamente).
    -eliminar [archivo]: Elimina el archivo pasado por parámetro.
.EXAMPLE
        ./ejercicio6.ps1 -eliminar archivo.txt

        ./EJ6.ps1 -listar

        ./EJ6.ps1 -recuperar "archivo.txt"

        ./EJ6.ps1 -vaciar        
.NOTES

# PowerShell
# cmdlets
#GRUPO

#TP: 2
#Ejercicio: 6
#Entrega: Segunda Reentrega

#INTEGRANTES:
# Kozak Hernán, 39288301
# Perrone Diego, 40021110
#
# Comisión: Martes y Jueves 
# Turno: Noche
#>

Param(
    [Parameter(Mandatory=$False)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript(
        {
            if((Test-path -path "$_" -pathType Leaf) -eq $True)
            {
                $True                   
            }else {
                Throw "$_ = error en el archivo especificado"
            }
        }
    )]
    [string] $eliminar,
    [Parameter(Mandatory=$false)]
    [switch] $listar=$false,
    [Parameter(Mandatory=$false)]
    [switch] $vaciar=$false,
    [Parameter(Mandatory=$False)]
    [ValidateNotNullOrEmpty()]
    [String]$recuperar
)


$papelera="papelera.zip"
$dirActual=get-location


function ValidarArchivoPapelera(){
	if(( Test-path -path "$home/$papelera" -pathType Leaf) -eq $False){
        cd $home
        mkdir papelera >$null   
        zip $papelera papelera >$null
        rm -r papelera
        cd "$dirActual"
    }
}


if($vaciar){
	ValidarArchivoPapelera
    cd $home
    rm $papelera
    mkdir papelera
    zip $papelera papelera >$null
    rm -r papelera
    cd $dirActual
}

if($listar){
    ValidarArchivoPapelera
    cd $home
    unzip $papelera >$null
    $archivos=get-childitem papelera
    if(($archivos).count -eq 0){
        "La papelera se encuentra actualmente vacía"
    }
    else{
        $table = New-Object System.Data.Datatable
        [void]$table.Columns.Add("Nombre")
        [void]$table.Columns.Add("Ruta Original")
        [void]$table.Columns.Add("Fecha Eliminación")

        foreach($archivo  in  $archivos){ 
            $stringArchivo="$archivo"
            $fecha=$stringArchivo.Substring($stringArchivo.LastIndexOf("*"))
            $fecha=$fecha.SubString(1)
            $fecha=$fecha.substring(1)
            $resto=$stringArchivo.Substring(0,$stringArchivo.LastIndexOf("*"))
            $nombre=$resto.Substring($resto.LastIndexOf("*"))
            $nombre=$nombre.SubString(1)
            $ruta=$resto.Substring($resto.IndexOf("*"))
            $ruta=$ruta.Substring(0, $ruta.lastIndexOf("*"))
            $ruta=$ruta.Replace("*","/")
            [void]$table.Rows.Add("$nombre","$ruta","$fecha")
        }
        $table
    }
    rm -r papelera
    cd $dirActual
}

elseif($recuperar){
    ValidarArchivoPapelera
    $archivoRec="$recuperar"
    cd $home
    unzip $papelera >$null
    $archivos=get-childitem papelera
    if(($archivos).count -eq 0){
        "La papelera se encuentra actualmente vacía"
        cd $dirActual
        exit 0
    }
    $contadorArchivos=0
    $tabla = New-Object System.Data.Datatable
    [void]$tabla.Columns.Add("Opción")
    [void]$tabla.Columns.Add("Nombre")
    [void]$tabla.Columns.Add("Ruta")
    [void]$tabla.Columns.Add("Fecha")

    $contador=0
    $opciones = [System.Collections.ArrayList]::new()

    foreach($archivo in $archivos){ 
        $stringArchivo="$archivo"
        $resto=$stringArchivo.Substring(0,$stringArchivo.LastIndexOf("*"))
        $nombre=$resto.Substring($resto.LastIndexOf("*"))
        $nombre=$nombre.SubString(1)
        if("$nombre" -eq "$archivoRec"){
            $contador++
            $fecha=$stringArchivo.Substring($stringArchivo.LastIndexOf("*"))
            $fecha=$fecha.SubString(1)
            $fecha=$fecha.substring(1)
            $ruta=$resto.Substring($resto.IndexOf("*"))
            $ruta=$ruta.Substring(0, $ruta.lastIndexOf("*"))
            $ruta=$ruta.Replace("*","/")
            [void]$tabla.Rows.Add("$contador","$nombre","$ruta","$fecha")
            $nombreArch=($stringArchivo.SubString($stringArchivo.LastIndexOf("/"))).subString(1)
            $opciones.Add("$nombreArch")>$null
        }
    }
    if($contador -eq 0){
        "No se encontró el archivo solicitado en la papelera"
    }
    else{
        if($contador -eq 1){
            cd papelera
            $ruta=$tabla.Ruta
            $nombreArch=$tabla.nombre
            $nombreEnZip=$opciones[0]
            mv $nombreEnZip $ruta/$nombreArch
        }else{
            "Se encontraron los siguientes archivos con ese nombre:" | out-host
            $tabla | out-host
            $Op = Read-Host "Cuál de las opciones desea eliminar?"
            if ($Op -gt $contador){
                "Opción inválida"
                rm -r papelera
                cd $dirActual
                exit 1
            }
            cd papelera
            $nombreEnZip=$opciones[$Op-1]
            $nombreArch=$tabla.Nombre[$Op-1]
            $rutaArch=$tabla.Ruta[$Op-1]
            mv $nombreEnZip $rutaArch/$nombreArch
        }
        cd $HOME
        rm $papelera
        zip -r $papelera "papelera">$null
        rm -r papelera
    }
    cd $dirActual
}

elseif($eliminar){
    ValidarArchivoPapelera
    $archivo=$(Resolve-Path  "$eliminar")
    if(!(Test-Path  "$archivo")){ 
        "Error en el path del archivo ingresado"
        exit  1 
    } try{
    $pruebaPermisos=get-content $archivo -ErrorAction Stop
    }catch{
        ""
        "error en el archivo a eliminar ingresado, no se poseen permisos"
        ""
        exit 1    
    }
    $fechaHora=get-date
    $fecha="$fechaHora"
    $fecha=$fecha.Replace("/","-")
    $path="$archivo"
    $pathR=$path.Substring(0, $path.LastIndexOf('/'))
    $archivoAsteriscos=$path.Replace("/","*")
    $nombreNuevo="$archivoAsteriscos*$fecha"
    cd $home
    unzip $papelera >$null
    mv $archivo "papelera/$nombreNuevo"
    zip -r $papelera papelera >$null
    rm -r papelera
    cd $dirActual
    "El archivo solicitado ya ha sido enviado a la papelera"
}