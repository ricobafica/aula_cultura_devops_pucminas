--USE frdatasqldbprd;

select --distinct --top 1000

-- dados da dbo.Pessoas
	 dboPessoas.CODPESSOA						AS 'dboPessoas COD_PESSOA'
	,dboPessoas.CGCCPF							AS 'dboPessoas CPF'
	,lower(dboPessoas.NOME)						AS 'dboPessoas NOME'

-- dados da fase
	,ultimoPdd.Id_Sgc							AS 'paPdd IdSGC'
	,ultimoPdd.Fase								AS 'paPdd FASE'
	,ultimoPdd.BairroComunidadeIdSgc			AS 'paPdd BAIRRO_COMUNIDADE_FASE1'
	,ultimoPdd.BairroComunidade					AS 'paPdd BAIRRO_COMUNIDADE_FASE2'

-- telefones
	--,sgsdimPessoas.ds_telefone				AS 'cmr_sgs.DimPessoas TELEFONE'
	,telPrincipal.TelefoneFormatado				AS 'erp_dbo_PessoaTelefone TELEFONE_FORMATADO'

-- endereços
    ,ultimoReq.[Endereco_Uf]		 			AS 'paReq RESIDENCIA UF'
	,ultimoReq.[Endereco_IdMunicipio]			AS 'paReq RESIDENCIA IdMUNICIPIO'
	,dbomunicipioResidencia.municipio			AS 'dboMunicipio RESIDENCIA_MUNICIPIO'
	,ultimoReq.[IdMunicipio_Origem]	 			AS 'paReq ORIGEM IdMUNICIPIO'
	,dbomunicipioOrigem.municipio	 			AS 'dboMunicipio ORIGEM_MUNICIPIO'

	,ultimoReq.[Endereco_Logradouro] 			AS 'paReq RESIDENCIA LOGRADOURO'
    ,ultimoReq.[Endereco_Numero]	 			AS 'paReq RESIDENCIA NUMERO'
	,ultimoReq.[Endereco_Bairro]	 			AS 'paReq RESIDENCIA BAIRRO'
	,ultimoReq.[Endereco_Complemento]			AS 'paReq RESIDENCIA COMPLEMENTO'
	,ultimoReq.[Endereco_Cep]		 			AS 'paReq RESIDENCIA CEP'
	,ultimoReq.[Telefone]			 			AS 'paReq RESIDENCIA TELEFONE'
	
-- pessoa grupo impacto	
	,pesgrupoImpact.Vinculo						AS 'pesgrupoImpact VINCULO'

-- detalhamento da classe PES_Pesca
	,Case	 
		When pesgrupoImpact.PES_Pesca_ProfissionalReg				='1' Then 'pesca profissional reg'
		When pesgrupoImpact.PES_Pesca_NaoRegulamentada				='1' Then 'pesca informal NAO reg'
		When pesgrupoImpact.PES_Pesca_Subsistencia					='1' Then 'pesca subsistencia'
		When pesgrupoImpact.PES_Pesca_Marisqueiro					='1' Then 'marisqueiro'
		When pesgrupoImpact.PES_Pesca_Mergulhador					='1' Then 'mergulhador'
		When pesgrupoImpact.PES_Pesca_ProfissionalReg_Estuarina		='1' Then 'pesca profissional reg estuarina'
		When pesgrupoImpact.PES_Pesca_ProfissionalReg_Continental	='1' Then 'pesca profissional reg continental'
		End 'pesgrupoImpact PES_PESCA'

-- concatenação de camaroeiros e caranguejeiros
	,Concat(
		 case when pesgrupoImpact.PES_Pesca_Camaroeiro		= 1		then 'camaroeiro '		end
		,case when pesgrupoImpact.PES_Pesca_Caranguejero	= 1		then 'caranguejeiro'	end
		) AS 'pesgrupoImpact PES_CRUSTACEOS'

-- detalhamento da classe PES_Comercioserv
	,Case	 -- subclasse de comercioserv	
		when pesgrupoImpact.PES_Comercioserv_AreiaArgila	= 1		then 'areia argila'		end
		AS	'pesgrupoImpact PES_COMERCIO_SERV'

-- detalhamento da classe PES_Extraçãomineral
	,Case	 -- subclasse de extracaomineral
		When pesgrupoImpact.PES_ExtracaoMineral_Areeiro		= 1		then 'areeiro'			end
		AS	'pesgrupoImpact PES_EXTRAÇÃO__MINERAL'

-- detalhamento da classe PES_Piscicultura
	,Case	 -- subclasse de piscicultura
		When pesgrupoImpact.PES_Piscicultura_TanqueRede		= 1 	then 'tanque rede'
		When pesgrupoImpact.PES_Piscicultura_TanqueEscavado	= 1 	then 'tanque escavado'	end
		AS	'pesgrupoImpact PES_PISCICULTURA'

-- detalhamento da classe PES_CadeiaPesca
	,Case	-- subclasse de cadeia_pesca
		When pesgrupoImpact.PES_CadeiaPesca_Produtiva		= 1		then 'produtiva'
		When pesgrupoImpact.Pes_CadeiaPesca_Beneficiamento	= 1		then 'beneficiamento'
		When pesgrupoImpact.Pes_CadeiaPesca_Comercializacao	= 1		then 'comercializacao'
		When pesgrupoImpact.Pes_CadeiaPesca_InsumoServico	= 1		then 'insumo servico'	end
		AS	'pesgrupoImpact PES_CADEIA_PESCA'

-- concatenação de revendedores formais e informais
	,Concat(
		 case when pesgrupoImpact.PES_CadeiaPesca_RevendedorFormal		= 1	then 'revendedor formal'	end
		,case when pesgrupoImpact.PES_CadeiaPesca_RevendedorInformal	= 1 then 'revendedor informal'	end
		) AS 'pesgrupoImpact PES_REVENDEDORES'

-- dados RDG (registro dano geral exclusivo no PIM) e RGP (registro geral de pesca)
	,benefRDG.ds_numero_rgp											AS 'benefRDG NUM_RDG'
	,STRING_AGG(benefRDG.[ds_rdg], ' || ')							AS 'benefRDG PROTOCOLO_DG'
	,STRING_AGG(benefRDG.[ds_status_rdg], ' || ')					AS 'benefRDG DG STATUS PROCESSO'
 	,STRING_AGG(benefRDG.[ds_motivo_status_rdg], ' || ')			AS 'benefRDG DG MOT_STATUS_PROCESSO'

-- informação sobre pgtos DG
	,IIF(pimDg.vl_total is not Null, 'Sim', 'Nao')					AS 'pimDG PGTO_PIM_DG'

-- dados RGP (registro geral de pesca)
	,CAST(pfRgp.NumeroRgp AS nvarchar)								AS 'pfRgp NUM_RGP'
	,CAST(dboDim14.nRGP		AS nvarchar)							AS 'dboDim14 RGP'    --4033 registros

-- pessoas reconhecidas pelo MAPA 
	,case
		when baseMapa.IdPortalAdvogadoBaseMapa is not null			then 'sim'	else	'não'	end
		AS 'baseMapa PESCADORES_RECONHECIDOS_PELO_MAPA'

--fim select principal

-- tabela pessoas junta todas as informações
from		stt_sgs.erp_dbo_pessoas													AS dboPessoas		-- 768.645 linhas

-- join entre dboPessoas e pesgrupoImpact informa sobre as pessoas na pesca
inner join	stt_sgs.syd_dbo_Itse_Pes_GruposImpacto									AS pesgrupoImpact	--  98.062 linhas
on			dboPessoas.CODPESSOA = pesgrupoImpact.CodPessoa		

-- join entre dboPessoas e paPdd informa sobre a fase

left join	(
			 select	
					 CodPessoa
					,Id_Sgc, Fase, BairroComunidadeIdSgc, BairroComunidade	
			 from	stt_sgs.erp_dg_PortalAdvogadoPessoaDanoDeclarado				AS paPdd			-- 295.605 linhas
			 where	IdPortalAdvogadoPessoaDanoDeclarado in
					(select
						max(IdPortalAdvogadoPessoaDanoDeclarado)
					 from	stt_sgs.erp_dg_PortalAdvogadoPessoaDanoDeclarado		AS paPdd
					 group by CodPessoa )														-- 232.576 linhas
			)																AS ultimoPdd		-- 232.576 linhas
on			dboPessoas.CODPESSOA = ultimoPdd.CodPessoa


-- join entre dboPessoas e sgsdimPessoas informa o telefone
left join	cmr_sgs.DimPessoas												AS sgsdimPessoas
on			dboPessoas.CODPESSOA = sgsdimPessoas.cd_pessoa


-- join entre dboPessoas e telPrincipal informa o telefone
left join	(select
				 codpessoa
				,TelefoneFormatado
			 from stt_sgs.erp_dbo_PessoaTelefone
			 where erp_dbo_PessoaTelefone.Principal = 1)					AS telPrincipal			--489.097 linhas
on			dboPessoas.CODPESSOA = telPrincipal.CodPessoa

-- join entre dboPessoas e ultimoReq informa sobre o ultimo requerimento

left join	(
			select
					 CodPessoa
					,Endereco_Uf, Endereco_IdMunicipio, IdMunicipio_Origem
					,Endereco_Logradouro, Endereco_Numero, Endereco_Bairro	 			
					,Endereco_Complemento, Endereco_Cep, Telefone
			from	stt_sgs.erp_dg_PortalAdvogadoRequerimento						AS paReq				-- 338.090 linhas
			where	IdPortalAdvogadoRequerimento IN
					(select
								max(paReq.IdPortalAdvogadoRequerimento)
								--,max(paReq1.DataPagamento_Requerente)
					 from		stt_sgs.erp_dg_PortalAdvogadoRequerimento			AS paReq
					 group by	paReq.CodPessoa	)												-- 210.796 linhas
			)																AS ultimoReq			-- 210.796 linhas
on			dboPessoas.CODPESSOA = ultimoReq.CodPessoa


-- join para extração de municipios

left join	stt_sgs.erp_dbo_Municipio												AS dbomunicipioResidencia
on			ultimoReq.[Endereco_IdMunicipio] = dbomunicipioResidencia.idmunicipio

left join	stt_sgs.erp_dbo_Municipio												AS dbomunicipioOrigem
on			ultimoReq.IdMunicipio_Origem = dbomunicipioOrigem.idMunicipio

-- join entre dboPessoas e pimDG
left join	[crt_sgs].mdPimDgControlePagamentoSemParametro					AS pimDg
on			dboPessoas.CODPESSOA = pimDg.cd_pessoa_escritorio

-- join entre dboPessoas e benefRDG
left join	[crt_sgs].[mdBeneficiariosRdg]									AS benefRDG
on			dboPessoas.CODPESSOA = benefRDG.Cd_Pessoa

-- join entre dboPessoas e pfRgp
left join	stt_sgs.erp_pf_Rgp														AS pfRgp
on			dboPessoas.CODPESSOA = pfRgp.CodPessoa

-- join entre dboPessoas e dboDim14 para RGP
left join	stt_sgs.syd_dbo_Dimensao_14										AS dboDim14
on			dboPessoas.CODPESSOA = dboDim14.id_sgc

-- join entre dboPessoas e baseMapa informa se pessoas na pesca
left join	stt_sgs.erp_dg_PortalAdvogadoBaseMapa									AS baseMapa
on			dboPessoas.CODPESSOA = baseMapa.CodPessoa


-- fim dos joins

--where		paPdd.Fase is null
GROUP BY dboPessoas.CODPESSOA
		,dboPessoas.CGCCPF
			,lower(dboPessoas.NOME)
	,ultimoPdd.Id_Sgc
	,ultimoPdd.Fase
	,ultimoPdd.BairroComunidadeIdSgc
	,ultimoPdd.BairroComunidade
	,telPrincipal.TelefoneFormatado
    ,ultimoReq.[Endereco_Uf]
	,ultimoReq.[Endereco_IdMunicipio]
	,dbomunicipioResidencia.municipio
	,ultimoReq.[IdMunicipio_Origem]
	,dbomunicipioOrigem.municipio
	,ultimoReq.[Endereco_Logradouro] 
    ,ultimoReq.[Endereco_Numero]
	,ultimoReq.[Endereco_Bairro]
	,ultimoReq.[Endereco_Complemento]
	,ultimoReq.[Endereco_Cep]
	,ultimoReq.[Telefone]
	,pesgrupoImpact.Vinculo
	,pesgrupoImpact.PES_Pesca_ProfissionalReg
	,pesgrupoImpact.PES_Pesca_NaoRegulamentada
	,pesgrupoImpact.PES_Pesca_Subsistencia
	,pesgrupoImpact.PES_Pesca_Marisqueiro
	,pesgrupoImpact.PES_Pesca_Mergulhador
	,pesgrupoImpact.PES_Pesca_ProfissionalReg_Estuarina
	,pesgrupoImpact.PES_Pesca_ProfissionalReg_Continental
	,pesgrupoImpact.PES_Pesca_Camaroeiro
	,pesgrupoImpact.PES_Pesca_Caranguejero
	,pesgrupoImpact.PES_Comercioserv_AreiaArgila
	,pesgrupoImpact.PES_ExtracaoMineral_Areeiro
	,pesgrupoImpact.PES_Piscicultura_TanqueRede
	,pesgrupoImpact.PES_Piscicultura_TanqueEscavado
	,pesgrupoImpact.PES_CadeiaPesca_Produtiva
	,pesgrupoImpact.Pes_CadeiaPesca_Beneficiamento
	,pesgrupoImpact.Pes_CadeiaPesca_Comercializacao
	,pesgrupoImpact.Pes_CadeiaPesca_InsumoServico
	,pesgrupoImpact.PES_CadeiaPesca_RevendedorFormal
	,pesgrupoImpact.PES_CadeiaPesca_RevendedorInformal
	,benefRDG.ds_numero_rgp		
	,pimDg.vl_total
	,pfRgp.NumeroRgp
	,dboDim14.nRGP
	,baseMapa.IdPortalAdvogadoBaseMapa
order by	'dboPessoas NOME';
