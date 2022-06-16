DECLARE
@fec_inicio Date,
@fec_fin Date,
@origen Char(16),
@destino Char(16)
select @fec_inicio = '20100101', @fec_fin = '20201008', @origen = 'MADRID', @destino = 'MURCIA';

WITH FECHAS(fecha) AS (
	SELECT @fec_inicio fecha
	UNION ALL
	SELECT DATEADD(day, 1, fecha) fecha
	FROM FECHAS
	WHERE fecha < @fec_fin
),

aux as (
	SELECT fecha, puntoOrigen, puntoDestino, envios,
			CASE WHEN producto in ('08:30Service','10:00Service','14:00Service','ASM 0830','ASM 10','ASM 14','ASM 24','ASM BUROFAX','ASM GO',
			'ASM GO PLUS','ASM Masivo','ASM PARCELSHOP','ASM PHARMA','BusinessParcel','CORREO INTERNO','DEVOLUCION',
			'ECONOMY','EconomyParcel','EUROBUSINESS','Franja Horaria','GLASS','INTERDIA','PICK','PREPAGADO','RC.SELLADA',
			'Rec. en NAVE.','Rec. INT','Rec. Sin Mercancia','Rec. WW','RECANALIZA','RETORNO','SERVICIO RUTAS',
			'SERVICIOS ESPECIALES','Srv. Navidad','Unitoque','VALIJA') then 'URGENTE' else 'NO URGENTE' end as tipo
	  FROM renvios_2
	  where puntoOrigen = @origen AND puntoDestino = @destino
)

select t1.fecha, @origen as puntoOrigen, @destino as puntoDestino, 'URGENTE' as tipo, n_envios, 
	DATEPART(dw, t1.fecha) as dia_semana, CONCAT(DATEPART(yyyy, t1.fecha), DATEPART(mm, t1.fecha)) as mes_anyo,
	DATEPART(yyyy, t1.fecha) as anyo, DATEPART(mm, t1.fecha) as mes
from FECHAS as t1
left join (
	SELECT fecha, @origen as puntoOrigen, @destino as puntoDestino, tipo, sum(envios) as n_envios
	from aux
	where fecha >= '2010-01-01'
	group by fecha, puntoOrigen, puntoDestino, tipo
) as t2
on t1.fecha = t2.fecha
OPTION (MaxRecursion 0)


DECLARE
@fec_inicio Date,
@fec_fin Date
select @fec_inicio = '20100101', @fec_fin = '20220331';

WITH FECHAS(fecha) AS (
	SELECT @fec_inicio fecha
	UNION ALL
	SELECT DATEADD(day, 1, fecha) fecha
	FROM FECHAS
	WHERE fecha < @fec_fin
),

aux as (
	SELECT fecha, sum(envios) as n_envios
	  FROM renvios_2
	  group by fecha
)

select t1.fecha, t2.n_envios, 
	DATEPART(dw, t1.fecha) as dia_semana, DATEPART(dd, t1.fecha) as dia_mes,
	DATEPART(mm, t1.fecha) as mes, DATEPART(yyyy, t1.fecha) as anyo
from FECHAS as t1
left join (
	SELECT fecha, n_envios
	from aux
	where fecha >= '2010-01-01'
) as t2
on t1.fecha = t2.fecha
order by fecha asc
OPTION (MaxRecursion 0)
