cd "D:/UAH/Tesis/cmf/Datos/bases/output"
use "fondos2012_2023.dta", clear

* Crear un identificador único para cada combinación fondo-serie
egen id_fs = group(fo_run fm_serie)
xtset id_fs fm_fecha

gen keep_date = 0

* Seleccionar las últimas fechas de cada mes de 2012 a 2023
forvalues year = 2012/2023 {
    foreach month in "jan" "mar" "may" "jul" "aug" "oct" "dec" {
        replace keep_date = 1 if fm_fecha == mdy(12, 31, `year')
    }
    foreach month in "apr" "jun" "sep" "nov" {
        replace keep_date = 1 if fm_fecha == mdy(12, 30, `year')
    }
    
    * Manejo de febrero considerando años bisiestos
    if mod(`year', 4) == 0 & (mod(`year', 100) != 0 | mod(`year', 400) == 0) {
        replace keep_date = 1 if fm_fecha == mdy(2, 29, `year')
    }
    else {
        replace keep_date = 1 if fm_fecha == mdy(2, 28, `year')
    }
}

* Filtrar solo las fechas seleccionadas
keep if keep_date == 1

* Convertir la fecha a formato mensual
gen fecha_mensual = mofd(fm_fecha)
format fecha_mensual %tm

* Reemplazar valores faltantes
replace factordeajuste = 1 if missing(factordeajuste)
replace factordereparto = 1 if missing(factordereparto)

* Ordenar datos por fondo-serie y tiempo
sort id_fs fecha_mensual

* Generar la variable rezagada para el valor de la cuota, permitiendo cambios de año
by id_fs: gen valor_cuota_lag = valor_cuota[_n-1] if month(dofm(fecha_mensual)) != 1
by id_fs: replace valor_cuota_lag = valor_cuota[_N] if month(dofm(fecha_mensual)) == 1 & year(dofm(fecha_mensual)) > year(dofm(fecha_mensual[1]))

* Calcular la rentabilidad mensual bruta
gen rentabilidad = (((valor_cuota / valor_cuota_lag) * factordeajuste * factordereparto) - 1) * 100

drop fecha_mensual keep_date valor_cuota valor_cuota_lag

save "rentabilidad_bruta.dta", replace
