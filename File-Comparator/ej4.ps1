<#
    .SYNOPSIS
    Este script comprueba la similitud entre archivos. 
    Para eso compara el archivo contra el resto corroborando que si la similitud 
    en número de líneas es mayor o igual al número pasado por parámetros el archivo 
    se considera similar al otro.
    .DESCRIPTION
    El presente script tiene dos parámetros obligatorios
	- El primero de ellos es --dir
	En el mismo se brinda el directorio de los archivos a verificar
    - El segundo es --ext
	En el mismo se brinda el archivo con las las extensiones a analizar

    Además tiene los siguientes parámetros optativos:
    - Porc
    Establece el porcentaje de similitud mínimo entre dos archivos. Por default es 0
    - Salida
    Sirve para brindar un archivo donde se guarde la información de salida
    - Coment (switch)
    Considera en la comparación las líneas comentadas
    - Sincoment (switch)
    No considera en la comparación las líneas comentadas
    .PARAMETER Dir
    Especifica el directorio a analizar (obligatorio)
    .PARAMETER Porc
    Porcentaje de similitud mínimo entre archivos.
    .PARAMETER Salida
    La información se guarda en el archivo especificado.
    .PARAMETER ext
    Archivo donde se encuentran las extensiones a comparar
    .PARAMETER coment
    Considera las líneas comentadas.
    .PARAMETER sincoment
    No considera las líneas comentadas
#>
<#
GRUPO

Palabra Script: ej5.ps1
TP: 2
Ejercicio: 5
Entregra: Tercera Reentrega

INTEGRANTES:

 Di Donato Melina, 38789046
 Kozak Hernán, 39288301
 Pere Alan Joaquin, 39063909
 Perrone Diego, 40021110
 Caputo Agustin, 36951459

Comisión: Martes y Jueves Turno: Noche

GRUPO
#>
Param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript(
        {
            if((Test-path "$_") -eq $True )
            {
                $True                   
            }else {
                Throw "$_ = error en el directorio de búsqueda ingresado"
            }
        }
    )]
    [string] $Dir,
    [Parameter(Mandatory=$True)]
    [ValidateNotNullOrEmpty()]
    [ValidateScript(
        {
            if((Test-path -path "$_" -pathType Leaf) -eq $True)
            {
                $True                   
            }else {
                Throw "$_ = error en el archivo de extensiones especificado"
            }
        }
    )]
    [string] $ext,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [ValidateRange(0,100)]
    [int] $porc = 0,
    [Parameter(Mandatory=$false)]
    [ValidateNotNullOrEmpty()]
    [string] $salida="",
    [Parameter(Mandatory=$false)]
    [switch] $coment=$false,
    [Parameter(Mandatory=$false)]
    [switch] $sincoment=$false
)
if ($coment -AND $sincoment ){
    Throw "Error, no es correcto que los parámetros coment y sincoment se envíen en simultáneo"
}

$user="$env:UserName"

try{
	$prueba=get-childItem $Dir -ErrorAction Stop
}catch{
    ""
	"error en el path de búsqueda ingresado, no se poseen permisos de lectura"
    ""
    exit 1
}
try{
	$prueba=get-childItem -file $Dir | Get-Content -ErrorAction Stop
}catch{
    ""
	"error en el path de búsqueda ingresado, no se poseen permisos de lectura para alguno de los archivos interiores"
    ""
    exit 1
}

try{
    $prueba2=get-content $ext -ErrorAction Stop
}catch{
    ""
	"error en el archivos de extensiones ingresado, no se poseen permisos de lectura"
    ""
    exit 1    
}

$extensiones=(get-content -path $ext).Split(";")

if($salida){
    "">$salida
}

$archivos=(get-childitem -R -file $dir).fullname

foreach ($extension in $extensiones) {
    $listado=@()
    foreach( $archivo in $archivos){
        if($archivo -like "*.$extension"){
            $listado+=$archivo
        }
    }
    foreach ($archivo in $listado) {
        $listado= $listado -ne "$archivo"
        if ($sincoment){
            $contArchivo1=(Get-ChildItem $archivo | Get-Content | Select-String -pattern "^#.*","^//.*" -notmatch)
        }else{ 
            $contArchivo1=(Get-ChildItem $archivo | Get-Content)
        }
        foreach ($archivo2 in $listado) {
            
            if ($sincoment){
                $contArchivo2=(Get-ChildItem $archivo2 | Get-Content | Select-String -pattern "^#.*","^//.*" -notmatch)
            }else{ 
                $contArchivo2=(Get-ChildItem $archivo2 | Get-Content)
            }

            $cantLineasArch1=$contArchivo1.count
            #Vemos cuántas lineas en común tienen
            $igual=(Compare-Object -ReferenceObject $contArchivo1 -DifferenceObject $contArchivo2 -IncludeEqual | Where-Object -FilterScript  {$_.SideIndicator -EQ '=='}).count
      
            $dif=($cantLineasArch1-$igual)   
            if($dif -gt $cantLineasArch1){
                $porcentaje=0
            }else{
                $porcentaje=($cantLineasArch1 - $dif)*100/($cantLineasArch1)
            }
            $porcentajeRedondo=[math]::round($porcentaje)
             
            if($porcentajeRedondo -gt $porc){
                " $archivo vs $archivo2"
                "La similitud entre los archivos es de $porcentajeRedondo%" 
                if ($salida){
                    " $archivo vs $archivo2" >> $salida
                    "La similitud entre los archivos es de $porcentajeRedondo%" >>$salida
                }
            }
        }
        ""
        if($salida){
            "">>$salida
        }
    }
}