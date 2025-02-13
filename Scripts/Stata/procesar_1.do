global bases "D:/UAH/Tesis/cmf/Datos"
global output "$bases/output"
global txt_diarias "$bases/txt_diarias"
global txt_costos "$bases/txt_costos"
*Unir archivos TXT mensuales de `cartolas diarias` (2012-2023)
********************************************************************************
cd "$txt_diarias"

local meses "ene feb mar abr may jun jul ago sep oct nov dic"
local years 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023

clear
tempfile combined_diarias
save `combined_diarias', emptyok  // Crear un dataset vacío

foreach year of local years {
    foreach mes of local meses {
        local filename "`mes'`year'.txt"
        capture import delimited using "`filename'", clear
        if _rc == 0 {
            append using `combined_diarias'
            save `combined_diarias', replace
        }
        else {
            display "`filename' no encontrado. Omitiendo..."
        }
    }
}

save "$output/cartolas2012_2023.dta", replace

*Unir archivos TXT mensuales de `cartolas de costos` (2012-2023)
********************************************************************************
cd "$txt_costos"

clear
tempfile combined_costos
save `combined_costos', emptyok  // Crear un dataset vacío

foreach year of local years {
    foreach mes of local meses {
        local filename "`mes'`year'.txt"
        capture import delimited using "`filename'", clear
        if _rc == 0 {
            append using `combined_costos'
            save `combined_costos', replace
        }
        else {
            display "`filename' no encontrado. Omitiendo..."
        }
    }
}

save "$output/costos2012_2023.dta", replace

 *Procesar y Fusionar Datos de Costos con Datos Diarios
********************************************************************************
use "$output/costos2012_2023.dta", clear

keep fo_run fm_serie fecha_inf rem_fija rem_variable gastos_afectos gastos_no_afectos ///
     comision_inversion comision_rescate factordeajuste factordereparto

sort fo_run fm_serie fecha_inf
tempfile dataset1
save `dataset1'

use "$output/cartolas2012_2023.dta", clear
keep fo_run fm_serie fecha_inf rem_fija rem_variable gastos_afectos gastos_no_afectos ///
     comision_inversion comision_rescate factordeajuste factordereparto

sort fo_run fm_serie fecha_inf
tempfile dataset2
save `dataset2'

merge 1:1 fo_run fm_serie fecha_inf using `dataset1'

*Corregir Valores Faltantes e Identificar Discrepancias
********************************************************************************
gen discrepancy = 0

foreach var in rem_fija rem_variable gastos_afectos gastos_no_afectos ///
                 comision_inversion comision_rescate factordeajuste factordereparto {
    replace `var' = `var'_using if missing(`var') & !missing(`var'_using)
}

* Identificar discrepancias cuando la diferencia absoluta > 10
foreach var in rem_fija rem_variable gastos_afectos gastos_no_afectos ///
                 comision_inversion comision_rescate factordeajuste factordereparto {
    gen diff_`var' = abs(`var' - `var'_using) > 10 if !missing(`var') & !missing(`var'_using)
    replace discrepancy = 1 if diff_`var' == 1
}

* Corregir valores cuando la diferencia es ≤ 10
foreach var in rem_fija rem_variable gastos_afectos gastos_no_afectos ///
                 comision_inversion comision_rescate factordeajuste factordereparto {
    replace `var' = `var'_using if abs(`var' - `var'_using) <= 10 & !missing(`var') & !missing(`var'_using)
}

 *Guardar Reporte de Discrepancias y Limpiar Datos
********************************************************************************
preserve
keep if discrepancy == 1
save "$bases/errores.dta", replace
export excel using "$bases/errores.xlsx", firstrow(variables) replace
restore

drop _merge
save "$output/fondos2012_2023.dta", replace
