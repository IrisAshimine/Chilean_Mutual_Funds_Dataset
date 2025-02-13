snapshot erase _all

global bases "D:/UAH/Tesis/cmf/Datos"
global output "$bases/output"

* Procesar la base de datos combinada
********************************************************************************

* Cargar la base de datos consolidada
use "$output/fondos2012_2023.dta", clear

* Convertir `fecha_inf` a formato de fecha en Stata
gen fm_fecha = daily(string(fecha_inf, "%8.0f"), "YMD")
format fm_fecha %td

* Calcular el patrimonio total del fondo
gen patrimonio = patrimonio_neto + gastos_afectos + gastos_no_afectos + rem_fija + rem_variable

* Calcular costos totales diarios
gen ct_diario = gastos_afectos + gastos_no_afectos + rem_fija + rem_variable + comision_rescate + comision_inversion

* Calcular la razón costo/patrimonio
gen cp_ratio = ct_diario / patrimonio

* Extraer el año de la fecha de informe
gen ano_fondo = year(fm_fecha)

* Calcular el TAC (Costo Total Anual)
********************************************************************************

* Contar el número de días registrados por serie y año
bysort run_fm serie ano_fondo: egen N = count(fm_fecha)

* Sumar la razón costo/patrimonio por serie y año
bysort run_fm serie ano_fondo: egen sum_ratio = total(cp_ratio)

* Calcular el TAC anual como porcentaje
gen tac_total = (sum_ratio / N) * 365 * 100

* Limpiar y guardar la base de datos
********************************************************************************

* Renombrar variables para mayor claridad
rename (nom_adm run_fm serie patrimonio_neto activo_tot num_participes moneda) ///
       (rg_razon_social fo_run fm_serie pat_net act_tot fm_npart fm_moneda)

* Guardar la base con información diaria
save "$output/tac_diaria.dta", replace

* Generar la base consolidada con un registro por serie y año
********************************************************************************

collapse (first) tac_total, by(rg_razon_social fo_run fm_serie ano_fondo)

* Guardar la base final con el TAC anual
save "$output/tac_anual.dta", replace

