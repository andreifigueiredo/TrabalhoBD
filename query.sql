CREATE TABLE naonormal.tudo(
	codigo_orgao_superior integer NOT NULL,
	nome_orgao_superior character varying(45) NOT NULL,
	codigo_orgao_subordinado integer NOT NULL,
	nome_orgao_subordinado character varying(45) NOT NULL,
	codigo_unidade_gestora integer NOT NULL,
	nome_unidade_gestora character varying(45) NOT NULL,
	codigo_funcao integer NOT NULL,
	nome_funcao character varying(100) NOT NULL,
	codigo_subfuncao integer NOT NULL,
	nome_subfuncao character varying(100) NOT NULL,
	codigo_programa integer NOT NULL,
	nome_programa character varying(150) NOT NULL,
	codigo_acao character varying(8) NOT NULL,
	nome_acao character varying(200) NOT NULL,
	linguagem_cidada character varying(300),
	cpf_favorecido character(14) NOT NULL,
	nome_favorecido character varying(45) NOT NULL,
	documento_pagamento character(12) NOT NULL,
	gestao_pagamento integer NOT NULL,
	data_pagamento date NOT NULL,
	valor_pagamento double precision NOT NULL
);

copy naonormal.tudo(
	codigo_orgao_superior,
	nome_orgao_superior,
	codigo_orgao_subordinado,
	nome_orgao_subordinado,
	codigo_unidade_gestora,
	nome_unidade_gestora,
	codigo_funcao,
	nome_funcao,
	codigo_subfuncao,
	nome_subfuncao,
	codigo_programa,
	nome_programa,
	codigo_acao,
	nome_acao,
	linguagem_cidada,
	cpf_favorecido,
	nome_favorecido,
	documento_pagamento,
	gestao_pagamento,
	data_pagamento,
	valor_pagamento
)
FROM 'C:\BD\201403_Diarias.tsv' DELIMITER '    '  CSV HEADER null as '';

create table normalizado.orgaosuperior(
    	id_orgaoSuperior int primary key,
	nomeOrgaoSuperior varchar(45) not null
);

create table normalizado.OrgaoSubordinado(
    	id_orgaoSubordinado int primary key,
	nomeOrgaoSubordinado varchar(45) not null,
	id_orgaoSuperior int references normalizado.OrgaoSuperior(id_orgaoSuperior) not null
);

create table normalizado.Funcao(
   	id_funcao int primary key,
nomeFuncao varchar(100) not null
);


create table normalizado.SubFuncao(
   	 id_subFuncao int primary key,
	nomeSubFuncao varchar(100) not null
);

create table normalizado.UnidadeGestora(
	id_unidadeGestora int primary key,
	nomeUnidadeGestora varchar(45) not null,
	id_orgaoSubordinado int references normalizado.OrgaoSubordinado(id_orgaoSubordinado)
);

create table normalizado.UnidadeFuncaoSubFuncao(
	id_unidadeGestora int references normalizado.UnidadeGestora(id_unidadeGestora),
	id_funcao int references normalizado.Funcao(id_funcao),
	id_subFuncao int references normalizado.SubFuncao(id_subFuncao),
	constraint FuncaoSubFuncao_pkey primary key (id_unidadeGestora,id_funcao, id_subFuncao)
);

create table normalizado.Favorecido(
	cpf varchar(14),
	nomeFavorecido varchar(45),
	primary key( cpf, nomeFavorecido)
);

create table normalizado.Acao(
	id_acao varchar(8) primary key,
	nomeAcao varchar(200),
	linguagemCidada varchar(300)
);


create table normalizado.Pagamento(
	id_unidadeGestora int references normalizado.UnidadeGestora(id_unidadeGestora),
	cpf char(14) not null,
	nomeFavorecido varchar(45) not null,
	foreign key (cpf, nomeFavorecido) references normalizado.Favorecido(cpf,nomeFavorecido),
	id_acao varchar(8) references normalizado.Acao(id_acao),
	documentoPagamento varchar(12) not null,
	gestaoPagamento int not null,
	dataPagamento date not null,
	valorPagamento float not null,
	primary key (id_unidadeGestora,cpf,nomeFavorecido,id_acao,documentoPagamento,valorpagamento)
);

create table normalizado.Programa(
	id_programa int primary key,
	nomePrograma varchar(150) not null
);



create table normalizado.ProgramaUnidadeGestora(
	id_programa int references normalizado.Programa(id_programa),
    id_unidadeGestora int references normalizado.UnidadeGestora(id_unidadeGestora),
	primary key (id_programa, id_unidadeGestora)
);


insert into normalizado.OrgaoSuperior(id_orgaoSuperior,nomeOrgaoSuperior)
select distinct codigo_orgao_superior, nome_orgao_superior
from naonormal.tudo;

insert into normalizado.OrgaoSubordinado(id_orgaoSubordinado,nomeOrgaoSubordinado,id_orgaoSuperior)
select distinct codigo_orgao_subordinado, nome_orgao_subordinado, codigo_orgao_superior
from naonormal.tudo;

insert into normalizado.Funcao(id_funcao,nomeFuncao)
select distinct codigo_funcao, nome_funcao
from naonormal.tudo;

insert into normalizado.subfuncao(id_subfuncao,nomeSubfuncao)
select distinct codigo_subfuncao, nome_subfuncao
from naonormal.tudo;

insert into normalizado.Favorecido(cpf,nomefavorecido)
select distinct cpf_favorecido, nome_favorecido
from naonormal.tudo;

insert into normalizado.Acao(id_acao,nomeacao,linguagemcidada)
select distinct codigo_acao, nome_acao, linguagem_cidada
from naonormal.tudo;

insert into normalizado.UnidadeGestora(id_unidadeGestora, nomeUnidadeGestora, id_orgaoSubordinado)
select distinct codigo_unidade_gestora, nome_unidade_gestora, codigo_orgao_subordinado
from naonormal.tudo;


insert into normalizado.Pagamento(id_unidadeGestora,cpf,nomefavorecido,id_acao,documentopagamento,gestaopagamento,datapagamento,valorpagamento)
select distinct codigo_unidade_gestora, cpf_favorecido, nome_favorecido, codigo_acao, documento_pagamento, gestao_pagamento, data_pagamento, valor_pagamento
from naonormal.tudo;

insert into normalizado.Programa(id_programa, nomePrograma)
select distinct codigo_programa, nome_programa
from naonormal.tudo;

insert into normalizado.UnidadeFuncaoSubfuncao(id_unidadeGestora, id_funcao, id_subfuncao)
select distinct codigo_unidade_gestora, codigo_funcao, codigo_subfuncao
from naonormal.tudo;

insert into normalizado.ProgramaUnidadeGestora(id_unidadegestora, id_programa)
select distinct codigo_unidade_gestora, codigo_programa
from naonormal.tudo;


A)
select nomefavorecido
from normalizado.pagamento
order by valorpagamento desc
limit 1;

select nomefavorecido
from normalizado.pagamento
where pagamento.valorpagamento = (select max(valorpagamento) from normalizado.pagamento);

B)
select soma from
	(select nomeOrgaosuperior, soma from
    	(select id_orgaosuperior, sum(soma) as soma from
        	(select id_orgaosubordinado, sum(soma) as soma from
            	(select id_unidadegestora, sum(valorpagamento) as soma
            	from normalizado.pagamento
       		 group by id_unidadegestora) as t1 join normalizado.unidadegestora
        	on unidadegestora.id_unidadegestora = t1.id_unidadegestora
        	group by id_orgaosubordinado) as t2 join normalizado.orgaosubordinado
    	on orgaosubordinado.id_orgaosubordinado = t2.id_orgaosubordinado
    	group by id_orgaosuperior) as t3 join normalizado.orgaoSuperior
	on orgaoSuperior.id_orgaosuperior = t3.id_orgaosuperior) as t4
where nomeOrgaosuperior like '%MINISTERIO DO PLANEJAMENTO%';


C)
select cpf, nomefavorecido from
	(select cpf,nomefavorecido,count(*) as contagem
	from normalizado.pagamento
	group by cpf,nomefavorecido) as t1
where contagem > 5;

D)
select nomePrograma from
	(select id_programa, soma from
    	(select id_programa, sum(soma) as soma from
        	(select id_unidadegestora, sum(valorpagamento) as soma
        	from normalizado.pagamento
        	group by id_unidadegestora) as t1 join normalizado.programaUnidadegestora
    	on programaUnidadegestora.id_unidadegestora = t1.id_unidadegestora
    	group by id_programa) as t2
	order by soma asc
	limit 1) as t3 join normalizado.programa
on t3.id_programa = programa.id_programa;

E)
select nomeorgaosuperior, nomeorgaosubordinado, nomeunidadegestora, nomefuncao, nomesubfuncao, nomeacao, nomeprograma, media from
    (select id_acao, media, nomeacao, id_unidadegestora, nomeunidadegestora, t9.id_orgaosubordinado, nomeorgaosubordinado, id_orgaosuperior, nomefuncao, nomesubfuncao, nomeprograma from
        (select id_acao, media, nomeacao, id_unidadegestora, nomeunidadegestora, id_orgaosubordinado, id_funcao, nomefuncao, id_subfuncao, nomesubfuncao, t8.id_programa, nomeprograma from
            (select id_acao, media, nomeacao, t7.id_unidadegestora, nomeunidadegestora, id_orgaosubordinado, id_funcao, nomefuncao, id_subfuncao, nomesubfuncao, id_programa from
                (select id_acao, media, nomeacao, id_unidadegestora, nomeunidadegestora, id_orgaosubordinado, id_funcao, nomefuncao, t6.id_subfuncao, nomesubfuncao from
                    (select id_acao, media, nomeacao, id_unidadegestora, nomeunidadegestora, id_orgaosubordinado, t5.id_funcao, nomefuncao, id_subfuncao from
                        (select id_acao, media, nomeacao, t4.id_unidadegestora, nomeunidadegestora, t4.id_orgaosubordinado, id_funcao, id_subfuncao from
                            (select t3.id_acao, media, nomeacao, t3.id_unidadegestora, nomeunidadegestora, id_orgaosubordinado from
                                (select t2.id_acao, media, nomeacao, id_unidadegestora from
                                    (select t1.id_acao, media, nomeacao from
                                        (select id_acao, avg(valorpagamento) as media from normalizado.pagamento group by id_acao order by id_acao ASC) as t1
                                    join normalizado.acao on acao.id_acao = t1.id_acao) as t2
                                join normalizado.pagamento on t2.id_acao = pagamento.id_acao group by t2.id_acao, t2.media, t2.nomeacao, id_unidadegestora) as t3
                            join normalizado.unidadegestora on t3.id_unidadegestora = unidadegestora.id_unidadegestora) as t4
                        join normalizado.unidadefuncaosubfuncao on t4.id_unidadegestora = unidadefuncaosubfuncao.id_unidadegestora) as t5
                    join normalizado.funcao on t5.id_funcao = funcao.id_funcao) as t6
                join normalizado.subfuncao on t6.id_subfuncao = subfuncao.id_subfuncao) as t7
            join normalizado.programaunidadegestora on t7.id_unidadegestora = programaunidadegestora.id_unidadegestora) as t8
        join normalizado.programa on t8.id_programa = programa.id_programa) as t9
    join normalizado.orgaosubordinado on t9.id_orgaosubordinado = orgaosubordinado.id_orgaosubordinado) as t10
join normalizado.orgaosuperior on t10.id_orgaosuperior = orgaosuperior.id_orgaosuperior
