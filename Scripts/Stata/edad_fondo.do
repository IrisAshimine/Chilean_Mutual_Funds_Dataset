
global bases "D:/UAH/Tesis/cmf/Datos"
global output "$bases/output"

*Importar y Procesar el Archivo `fm_ident.txt`
********************************************************************************
cd "$bases"
import delimited using "$bases/fm_ident.txt", clear

* Reemplazar fechas de término faltantes con "31/12/2023"
replace fechatérminooperaciones = "31/12/2023" if mi(fechatérminooperaciones)

* Convertir fechas desde formato DD/MM/YYYY a formato Stata
gen fecha_inicio = date(fechainiciooperaciones, "DMY")
gen fecha_fin = date(fechatérminooperaciones, "DMY")

* Formatear las fechas para mejor visualización
format fecha_inicio fecha_fin %td

* Seleccionar solo las variables relevantes
keep fecha_inicio fecha_fin runfondo rutadministradora moneda tipodefondomutuo vida_dias vida_fondo

* Renombrar variables para mayor claridad
rename (runfondo rutadministradora moneda tipodefondomutuo) (fo_run rut_agf fm_moneda tipo_fondo)

* Guardar la base de datos procesada
save "$output/vida_fondo.dta", replace

* Cargar y Fusionar `vida_fondo` con `tac_anual`
********************************************************************************
use "$output/tac_anual.dta", clear

* Fusionar con la base `vida_fondo`
merge m:1 fo_run using "$output/vida_fondo.dta"

* Verificar la fusión
tab _merge

* Eliminar la variable _merge después de revisar
drop _merge

* Calcular la Edad del Fondo al Final de Cada Año
********************************************************************************

* Convertir `fecha_inicio` y `fecha_fin` a formato Stata
gen start_date = date(fecha_inicio, "YMD")
gen end_date = date(fecha_fin, "YMD")
format start_date end_date %td

* Calcular la cantidad de días desde la creación del fondo hasta `fm_fecha`
gen age_days = fm_fecha - start_date

* Convertir a años suponiendo 365 días por año
gen age_years = age_days / 365

* Evitar valores incorrectos:
replace age_years = . if fm_fecha < start_date  // No mostrar antes de la creación
replace age_years = . if fm_fecha > end_date    // No mostrar después del cierre

save "$output/tac_anual.dta", replace
