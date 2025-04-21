CREATE DATABASE SGD;
USE SGD;

-- Parte 1 --
BEGIN TRY

-- Criação da Estrutura de Dados
CREATE TABLE TIPO_DOCUMENTO (
    ID_Tipo_Documento INT IDENTITY(1,1) NOT NULL,
    Nome NVARCHAR(100) NOT NULL,
    Descricao NVARCHAR(200),
    Campos_Obrigatorios NVARCHAR(2000) NOT NULL, 
    Prazo_Padrao_Processamento INT NOT NULL,
    PRIMARY KEY (ID_Tipo_Documento),
    CONSTRAINT UC_NomeTipoDocumento UNIQUE (Nome)
);

CREATE TABLE UNIDADE_ORGANICA (
    ID_UO INT IDENTITY(1,1) NOT NULL,
    Nome NVARCHAR(100) NOT NULL,
    Descricao NVARCHAR(2000),
    Nivel_Hierarquico INT NOT NULL,
    PRIMARY KEY (ID_UO),
    CONSTRAINT UC_NomeUO UNIQUE (Nome)
);

CREATE TABLE ESTADO_DOCUMENTO (
    ID_Estado INT IDENTITY(1,1) NOT NULL,
    Nome NVARCHAR(50) NOT NULL,
    Descricao NVARCHAR(200),
    PRIMARY KEY (ID_Estado),
    CONSTRAINT UC_NomeEstado UNIQUE (Nome)
);

CREATE TABLE UTILIZADOR (
    ID_Utilizador INT IDENTITY(1,1) NOT NULL,
    ID_UO INT NOT NULL,
    Nome NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL,
    Cargo NVARCHAR(50),
    Telefone NVARCHAR(50),
    Nivel_Autorizacao INT NOT NULL,
    Estado NVARCHAR(50) NOT NULL,
    ID_Supervisor INT NOT NULL,
    PRIMARY KEY (ID_Utilizador),
    FOREIGN KEY (ID_UO) REFERENCES UNIDADE_ORGANICA(ID_UO),
    FOREIGN KEY (ID_Supervisor) REFERENCES UTILIZADOR(ID_Utilizador),
    UNIQUE (Email)
);

CREATE TABLE DOCUMENTO (
    ID_Documento INT IDENTITY(1,1) NOT NULL,
    ID_Tipo_Documento INT NOT NULL,
    ID_Processo INT NOT NULL,
    ID_Estado INT NOT NULL,
    Descricao NVARCHAR(2000) NOT NULL,
    Data_Criacao DATE DEFAULT '2000-01-01',
    Data_Insercao DATETIME DEFAULT GETDATE(),
    Data_Emissao DATE,
    Data_Digitalizacao DATE,
    Formato NVARCHAR(50) NOT NULL,
    Confidencial BIT NOT NULL DEFAULT 0,
    Hiden BIT NOT NULL DEFAULT 0,
    PRIMARY KEY (ID_Documento),
    FOREIGN KEY (ID_Tipo_Documento) REFERENCES TIPO_DOCUMENTO(ID_Tipo_Documento),
    FOREIGN KEY (ID_Estado) REFERENCES ESTADO_DOCUMENTO(ID_Estado)
);

CREATE TABLE PROCESSO (
    ID_Processo INT IDENTITY(1,1) NOT NULL,
    ID_Documento INT NOT NULL,
    Estado_Atual NVARCHAR(50) NOT NULL,
    Data_Inicio DATETIME NOT NULL,
    Prazo DATETIME NOT NULL,
    Estado_Aprovacao NVARCHAR(50),
    PRIMARY KEY (ID_Processo),
    FOREIGN KEY (ID_Documento) REFERENCES DOCUMENTO(ID_Documento),
    UNIQUE (ID_Documento)
);

ALTER TABLE DOCUMENTO
ADD CONSTRAINT FK_Processo
FOREIGN KEY (ID_Processo) REFERENCES PROCESSO(ID_Processo);

CREATE TABLE ARQUIVO_FISICO (
    ID_Arquivo INT IDENTITY(1,1) NOT NULL,
    ID_Documento INT NOT NULL,
    Localizacao NVARCHAR(50) NOT NULL,
    Referencia_Catalogo NVARCHAR(50) NOT NULL,
    Data_Arquivamento DATETIME NOT NULL,
    Estado NVARCHAR(50) NOT NULL,
    Responsavel_Arquivamento NVARCHAR(50),
    PRIMARY KEY (ID_Arquivo),
    FOREIGN KEY (ID_Documento) REFERENCES DOCUMENTO(ID_Documento),
    UNIQUE (ID_Documento)
);

CREATE TABLE REGRA_ENCAMINHAMENTO (
    ID_Regra INT IDENTITY(1,1) NOT NULL,
    ID_Tipo_Documento INT NOT NULL,
    Condicao_Valor_Limite BIT DEFAULT 0,
    Valor_Limite DECIMAL(10,2),
    Prazo_Resposta INT NOT NULL,
    Nivel_Escalacao INT,
    Tipo_Notificacao NVARCHAR(50) NOT NULL,
    PRIMARY KEY (ID_Regra),
    FOREIGN KEY (ID_Tipo_Documento) REFERENCES TIPO_DOCUMENTO(ID_Tipo_Documento)
);

CREATE TABLE NOTIFICACAO (
    ID_Notificacao INT IDENTITY(1,1) NOT NULL,
    ID_Utilizador_Destino INT NOT NULL,
    ID_Processo INT NOT NULL,
    Data_Envio DATE NOT NULL,
    Estado_Envio NVARCHAR(50) NOT NULL,
    Conteudo NVARCHAR(2000) NOT NULL,
    Tipo_Notificacao NVARCHAR(50) NOT NULL, 
    Data_Leitura DATE,
    PRIMARY KEY (ID_Notificacao),
    FOREIGN KEY (ID_Utilizador_Destino) REFERENCES UTILIZADOR(ID_Utilizador),
    FOREIGN KEY (ID_Processo) REFERENCES PROCESSO(ID_Processo)
);

CREATE TABLE LOG_ATIVIDADE (
    ID_Log INT IDENTITY(1,1) NOT NULL,
    ID_Utilizador INT NOT NULL,
    ID_Documento INT NOT NULL,
    Tipo_Acao NVARCHAR(50) NOT NULL,
    Data_Hora DATETIME NOT NULL,
    Descricao NVARCHAR(2000) NOT NULL,
    IP_Utilizador NVARCHAR(50) NULL,
    Estado_Acao NVARCHAR(50) NOT NULL,
    PRIMARY KEY (ID_Log),
    FOREIGN KEY (ID_Documento) REFERENCES DOCUMENTO(ID_Documento),
    FOREIGN KEY (ID_Utilizador) REFERENCES UTILIZADOR(ID_Utilizador)
);

CREATE TABLE DOCUMENTO_UO (
    ID_Documento INT NOT NULL,
    ID_UO INT NOT NULL,
    PRIMARY KEY (ID_Documento, ID_UO),
    FOREIGN KEY (ID_Documento) REFERENCES DOCUMENTO(ID_Documento),
    FOREIGN KEY (ID_UO) REFERENCES UNIDADE_ORGANICA(ID_UO)
);

CREATE TABLE PROCESSO_REGRA (
    ID_Processo INT NOT NULL,
    ID_Regra INT NOT NULL,
    Estado_Aplicacao NVARCHAR(50) NOT NULL,
    Data_Aplicacao DATETIME NOT NULL,
    PRIMARY KEY (ID_Processo, ID_Regra),
    FOREIGN KEY (ID_Processo) REFERENCES PROCESSO(ID_Processo),
    FOREIGN KEY (ID_Regra) REFERENCES REGRA_ENCAMINHAMENTO(ID_Regra)
);

CREATE TABLE UO_REGRA (
    ID_UO INT NOT NULL,
    ID_Regra INT NOT NULL,
    Ordem_Execucao NVARCHAR(50) NOT NULL,
    Tipo_Participacao NVARCHAR(50) NOT NULL,
    PRIMARY KEY (ID_UO , ID_Regra),
    FOREIGN KEY (ID_UO)
    REFERENCES UNIDADE_ORGANICA (ID_UO),
    FOREIGN KEY (ID_Regra)
    REFERENCES REGRA_ENCAMINHAMENTO (ID_Regra)
);

CREATE TABLE CAMPO_DOCUMENTO (
    ID_Campo INT IDENTITY(1,1),
    ID_Documento INT NOT NULL,
    Nome_Campo NVARCHAR(100) NOT NULL,
    Valor_Campo NVARCHAR(MAX),
    PRIMARY KEY (ID_Campo),
    FOREIGN KEY (ID_Documento) REFERENCES DOCUMENTO(ID_Documento)
);

END TRY
BEGIN CATCH 
    SELECT ERROR_NUMBER() AS ErrorNumber
    ,ERROR_SEVERITY() AS ErrorSeverity
    ,ERROR_STATE() AS ErrorState
    ,ERROR_PROCEDURE() AS ErrorProcedure
    ,ERROR_LINE() AS ErrorLine
    ,ERROR_MESSAGE() AS ErrorMessage;
    ROLLBACK;
    PRINT 'Erro encontrado: ' + ERROR_MESSAGE();
END CATCH;

-- Parte 2 --
BEGIN TRY
    BEGIN TRANSACTION;
-- Inserção de Dados
-- Garantir que o SGD incorpora de base pelo menos 5 tipos de documentos diferentes.
INSERT INTO TIPO_DOCUMENTO (Nome, Descricao, Campos_Obrigatorios, Prazo_Padrao_Processamento) VALUES
('Fatura', 'Documento fiscal', 'Numero_Documento,NIPC_Vendedor,NIF_NIPC_Comprador,Data,Valor_Total', 7),
('Certidão', 'Documento oficial', 'Número, Nome, Data Expiração', 15),
('Relatório', 'Documento de análise', 'Título, Data, Autor', 30),
('Ofício', 'Comunicação oficial', 'Número, Remetente, Data', 10),
('Contrato', 'Documento legal', 'Partes, Data, Assinatura', 60);

SELECT * FROM TIPO_DOCUMENTO;

-- Garantir que o SGD incorpora de base pelo menos 5 tipos de estados diferentes
INSERT INTO ESTADO_DOCUMENTO (Nome, Descricao) VALUES
('Criado', 'Documento recém-criado no sistema'),
('Em Processamento', 'Documento está sendo processado'),
('Aguardando Aprovação', 'Documento aguarda aprovação de um superior'),
('Aprovado', 'Documento foi aprovado e está pronto para próximas etapas'),
('Arquivado', 'Documento foi processado e arquivado');

SELECT * FROM ESTADO_DOCUMENTO;

-- Garantir que o SGD incorpora de base pelo menos 5 Unidades Orgânicas (UO)
INSERT INTO UNIDADE_ORGANICA (Nome, Descricao, Nivel_Hierarquico) VALUES
('Departamento Financeiro', 'Responsável pela gestão financeira e contabilidade', 1),
('Recursos Humanos', 'Gerencia o capital humano da organização', 1),
('Departamento de TI', 'Responsável pela infraestrutura e sistemas de informação', 1),
('Departamento Jurídico', 'Lida com questões legais e contratuais', 1),
('Departamento de Marketing', 'Responsável pela promoção e imagem da empresa', 1);

SELECT * FROM UNIDADE_ORGANICA;

-- Garantir que o SGD incorpora de base pelo menos 10 utilizadores (funcionários)
INSERT INTO UTILIZADOR (ID_UO, Nome, Email, Cargo, Telefone, Nivel_Autorizacao, Estado, ID_Supervisor) VALUES
(1, 'João Silva', 'joao.silva@empresa.pt', 'Diretor Financeiro', '912345678', 5, 'Ativo', 1),
(2, 'Maria Santos', 'maria.santos@empresa.pt', 'Gerente de RH', '923456789', 4, 'Ativo', 1),
(3, 'Pedro Costa', 'pedro.costa@empresa.pt', 'Coordenador de TI', '934567890', 4, 'Ativo', 1),
(4, 'Ana Ferreira', 'ana.ferreira@empresa.pt', 'Advogada Sénior', '945678901', 4, 'Ativo', 1),
(5, 'Carlos Mendes', 'carlos.mendes@empresa.pt', 'Gerente de Marketing', '956789012', 4, 'Ativo', 1),
(1, 'Sofia Rodrigues', 'sofia.rodrigues@empresa.pt', 'Analista Financeiro', '967890123', 3, 'Ativo', 1),
(2, 'Ricardo Pereira', 'ricardo.pereira@empresa.pt', 'Assistente de RH', '978901234', 2, 'Ativo', 2),
(3, 'Mariana Alves', 'mariana.alves@empresa.pt', 'Analista de Sistemas', '989012345', 3, 'Ativo', 3),
(4, 'Tiago Oliveira', 'tiago.oliveira@empresa.pt', 'Assistente Jurídico', '990123456', 2, 'Ativo', 4),
(5, 'Inês Gomes', 'ines.gomes@empresa.pt', 'Analista de Marketing', '901234567', 3, 'Ativo', 5);

SELECT * FROM UTILIZADOR;

-- Garantir que o SGD já tem registados pelo menos 10 documentos
-- Aterar a tabela DOCUMENTO para permitir ID_Processo NULL temporariamente
ALTER TABLE DOCUMENTO
ALTER COLUMN ID_Processo INT NULL;

-- Inserir os documentos
INSERT INTO DOCUMENTO (ID_Tipo_Documento, ID_Estado, Descricao, Data_Criacao, Data_Emissao, Data_Digitalizacao, Formato, Confidencial, Hiden) VALUES
(1, 1, 'Fatura de compra de equipamentos', '2024-01-15', '2024-01-14', '2024-01-15', 'PDF', 0, 0),
(2, 2, 'Certidão de não dívida', '2024-01-16', '2024-01-10', '2024-01-16', 'PDF', 0, 0),
(3, 3, 'Relatório anual de vendas', '2024-01-17', '2024-01-05', '2024-01-17', 'DOCX', 0, 0),
(4, 4, 'Ofício para parceiro comercial', '2024-01-18', '2024-01-17', '2024-01-18', 'PDF', 0, 0),
(5, 5, 'Contrato de prestação de serviços', '2024-01-19', '2024-01-12', '2024-01-19', 'PDF', 0, 0),
(1, 2, 'Fatura de serviços de consultoria', '2024-01-20', '2024-01-19', '2024-01-20', 'PDF', 0, 0),
(2, 2, 'Certidão de registro comercial', '2024-01-21', '2024-01-15', '2024-01-21', 'PDF', 0, 0),
(3, 1, 'Relatório de despesas do mês', '2024-01-22', '2024-01-21', '2024-01-22', 'XLSX', 0, 0),
(4, 3, 'Ofício de solicitação de informações', '2024-01-23', '2024-01-22', '2024-01-23', 'PDF', 1, 0),
(5, 4, 'Contrato de aluguel de equipamentos', '2024-01-24', '2024-01-20', '2024-01-24', 'PDF', 0, 0);

SELECT * FROM DOCUMENTO;

-- Criar os processos correspondentes
INSERT INTO PROCESSO (ID_Documento, Estado_Atual, Data_Inicio, Prazo, Estado_Aprovacao) VALUES
(1, 'Iniciado', '2024-01-15', '2024-01-22', 'Pendente'),
(2, 'Em Andamento', '2024-01-16', '2024-01-31', 'Pendente'),
(3, 'Em Revisão', '2024-01-17', '2024-02-16', 'Pendente'),
(4, 'Aprovado', '2024-01-18', '2024-01-28', 'Aprovado'),
(5, 'Arquivado', '2024-01-19', '2024-03-19', 'Aprovado'),
(6, 'Em Andamento', '2024-01-20', '2024-01-27', 'Pendente'),
(7, 'Em Andamento', '2024-01-21', '2024-02-05', 'Pendente'),
(8, 'Iniciado', '2024-01-22', '2024-02-21', 'Pendente'),
(9, 'Em Revisão', '2024-01-23', '2024-02-02', 'Pendente'),
(10, 'Aprovado', '2024-01-24', '2024-03-24', 'Aprovado');

-- Atualizar os documentos com seus respectivos ID_Processo
UPDATE DOCUMENTO SET ID_Processo = 1 WHERE ID_Documento = 1;
UPDATE DOCUMENTO SET ID_Processo = 2 WHERE ID_Documento = 2;
UPDATE DOCUMENTO SET ID_Processo = 3 WHERE ID_Documento = 3;
UPDATE DOCUMENTO SET ID_Processo = 4 WHERE ID_Documento = 4;
UPDATE DOCUMENTO SET ID_Processo = 5 WHERE ID_Documento = 5;
UPDATE DOCUMENTO SET ID_Processo = 6 WHERE ID_Documento = 6;
UPDATE DOCUMENTO SET ID_Processo = 7 WHERE ID_Documento = 7;
UPDATE DOCUMENTO SET ID_Processo = 8 WHERE ID_Documento = 8;
UPDATE DOCUMENTO SET ID_Processo = 9 WHERE ID_Documento = 9;
UPDATE DOCUMENTO SET ID_Processo = 10 WHERE ID_Documento = 10;

ALTER TABLE DOCUMENTO
ALTER COLUMN ID_Processo INT NOT NULL;

SELECT * FROM PROCESSO;

-- Campos do tipo FATURA
INSERT INTO CAMPO_DOCUMENTO (ID_Documento, Nome_Campo, Valor_Campo)  VALUES 
(1, 'Numero_Documento', '12345'),
(1, 'NIPC_Vendedor', '123456789'),
(1, 'NIF_NIPC_Comprador', '987654321'),
(1, 'Data', '2024-01-15'),
(1, 'Valor_Total', '1000.00');

-- Campos do tipo CERTIDAO
INSERT INTO CAMPO_DOCUMENTO (ID_Documento, Nome_Campo, Valor_Campo) 
VALUES 
(2, 'Numero_Documento', '67890'),
(2, 'Nome_Certidao', 'Certidão de Nascimento'),
(2, 'Data_Expiracao', '2025-01-15');

SELECT * FROM CAMPO_DOCUMENTO;

-- Inserir registos na tabela ARQUIVO_FISICO
INSERT INTO ARQUIVO_FISICO (ID_Documento, Localizacao, Referencia_Catalogo, Data_Arquivamento, Estado, Responsavel_Arquivamento) VALUES 
(5, 'Prateleira A, Secção 3', 'CTR-2024-001', '2024-01-19 15:30:00', 'Arquivado', 'Ana Ferreira'),
(4, 'Prateleira B, Secção 1', 'OFC-2024-001', '2024-01-18 14:45:00', 'Arquivado', 'Tiago Oliveira'),
(2, 'Prateleira C, Secção 2', 'CRT-2024-001', '2024-01-16 16:00:00', 'Em Processamento', 'Maria Santos');

SELECT * FROM ARQUIVO_FISICO;

-- Inserir registos na tabela REGRA_ENCAMINHAMENTO
INSERT INTO REGRA_ENCAMINHAMENTO (ID_Tipo_Documento, Condicao_Valor_Limite, Valor_Limite, Prazo_Resposta, Nivel_Escalacao, Tipo_Notificacao) VALUES 
(1, 1, 5000.00, 3, 2, 'Email'),
(3, 0, NULL, 5, 1, 'SMS'),
(5, 1, 10000.00, 7, 3, 'Email e SMS');

SELECT * FROM REGRA_ENCAMINHAMENTO;

-- Inserir registos na tabela NOTIFICACAO
INSERT INTO NOTIFICACAO (ID_Utilizador_Destino, ID_Processo, Data_Envio, Estado_Envio, Conteudo, Tipo_Notificacao, Data_Leitura) VALUES 
(1, 1, '2024-01-15', 'Enviado', 'Nova fatura para aprovação', 'Email', '2024-01-15 10:30:00'),
(3, 3, '2024-01-17', 'Enviado', 'Relatório anual pronto para revisão', 'SMS', '2024-01-17 09:15:00'),
(4, 5, '2024-01-19', 'Enviado', 'Contrato arquivado com sucesso', 'Email', NULL);

SELECT * FROM NOTIFICACAO;

-- Inserir registos na tabela LOG_ATIVIDADE
SET IDENTITY_INSERT LOG_ATIVIDADE ON
INSERT INTO LOG_ATIVIDADE (ID_Log, ID_Utilizador, ID_Documento, Tipo_Acao, Data_Hora, Descricao, IP_Utilizador, Estado_Acao) VALUES 
(1, 1, 1, 'Criação', GETDATE(), 'Documento criado', '192.168.1.100', 'Concluído'),
(2, 2, 1, 'Visualização', DATEADD(HOUR, 1, GETDATE()), 'Documento visualizado', '192.168.1.101', 'Concluído'),
(3, 3, 2, 'Edição', DATEADD(HOUR, 2, GETDATE()), 'Documento editado', '192.168.1.102', 'Concluído');
SET IDENTITY_INSERT LOG_ATIVIDADE OFF

SELECT * FROM LOG_ATIVIDADE;

-- Inserir registos na tabela DOCUMENTO_UO 
INSERT INTO DOCUMENTO_UO (ID_Documento, ID_UO) VALUES 
(1, 1), 
(2, 1),
(3, 1),
(4, 4);

SELECT * FROM DOCUMENTO_UO;

    COMMIT TRANSACTION;
    PRINT 'Todas as inserções foram concluídas com sucesso.';

END TRY
BEGIN CATCH 
    SELECT ERROR_NUMBER() AS ErrorNumber
    ,ERROR_SEVERITY() AS ErrorSeverity
    ,ERROR_STATE() AS ErrorState
    ,ERROR_PROCEDURE() AS ErrorProcedure
    ,ERROR_LINE() AS ErrorLine
    ,ERROR_MESSAGE() AS ErrorMessage;
    ROLLBACK TRANSACTION;
    PRINT 'Erro encontrado: ' + ERROR_MESSAGE();
END CATCH;

BEGIN TRY
-- Listagens
-- Listagem de todos os documentos de uma UO (Departamento Financeiro) com seus respectivos estados
SELECT 
    d.ID_Documento,
    td.Nome AS Tipo_Documento,
    d.Descricao,
    ed.Nome AS Estado_Documento,
    d.Data_Criacao,
    d.Data_Emissao,
    uo.Nome AS Unidade_Organizacional
FROM 
    DOCUMENTO d
JOIN 
    TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
JOIN 
    ESTADO_DOCUMENTO ed ON d.ID_Estado = ed.ID_Estado
JOIN 
    DOCUMENTO_UO dou ON d.ID_Documento = dou.ID_Documento
JOIN 
    UNIDADE_ORGANICA uo ON dou.ID_UO = uo.ID_UO
WHERE 
    uo.Nome = 'Departamento Financeiro'
ORDER BY 
    d.Data_Criacao DESC; 

-- Listagem de todos os documentos em um determinado estado (Ex: "Em Andamento") e suas respectivas UOs
SELECT 
    d.ID_Documento,
    td.Nome AS Tipo_Documento,
    d.Descricao,
    ed.Nome AS Estado_Documento,
    d.Data_Criacao,
    d.Data_Emissao,
    uo.Nome AS Unidade_Organizacional
FROM 
    DOCUMENTO d
JOIN 
    TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
JOIN 
    ESTADO_DOCUMENTO ed ON d.ID_Estado = ed.ID_Estado
JOIN 
    DOCUMENTO_UO dou ON d.ID_Documento = dou.ID_Documento
JOIN 
    UNIDADE_ORGANICA uo ON dou.ID_UO = uo.ID_UO
JOIN 
    PROCESSO p ON d.ID_Processo = p.ID_Processo
WHERE 
    p.Estado_Atual = 'Em Andamento'
ORDER BY 
    uo.Nome, d.Data_Criacao DESC;

-- Listagem do workflow completo do documento com ID 3
DECLARE @ID_Documento INT = 3;

SELECT 
    d.ID_Documento,
    td.Nome AS Tipo_Documento,
    d.Descricao AS Descricao_Documento,
    la.Data_Hora,
    la.Tipo_Acao,
    la.Descricao AS Descricao_Acao,
    la.Estado_Acao,
    u.Nome AS Usuario_Responsavel,
    p.Estado_Atual AS Estado_Processo,
    p.Estado_Aprovacao
FROM 
    DOCUMENTO d
JOIN 
    TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
LEFT JOIN 
    LOG_ATIVIDADE la ON d.ID_Documento = la.ID_Documento
LEFT JOIN 
    UTILIZADOR u ON la.ID_Utilizador = u.ID_Utilizador
LEFT JOIN 
    PROCESSO p ON d.ID_Processo = p.ID_Processo
WHERE 
    d.ID_Documento = @ID_Documento
ORDER BY 
    la.Data_Hora ASC;

-- Listagem de todos os documentos entrados em 22 de janeiro de 2024
DECLARE @DataEntrada DATE = '2024-01-22';

SELECT 
    d.ID_Documento,
    td.Nome AS Tipo_Documento,
    d.Descricao,
    d.Data_Criacao,
    d.Data_Emissao,
    d.Formato,
    p.Estado_Atual AS Estado_Processo,
    uo.Nome AS Unidade_Organizacional
FROM 
    DOCUMENTO d
JOIN 
    TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
JOIN 
    PROCESSO p ON d.ID_Processo = p.ID_Processo
LEFT JOIN 
    DOCUMENTO_UO dou ON d.ID_Documento = dou.ID_Documento
LEFT JOIN 
    UNIDADE_ORGANICA uo ON dou.ID_UO = uo.ID_UO
WHERE 
    CAST(d.Data_Criacao AS DATE) = @DataEntrada
ORDER BY 
    d.Data_Criacao;

-- Listagem de todos os documentos entrados em 22 de janeiro de 2024 com seu estado atual e UO
DECLARE @DataEntrada1 DATE = '2024-01-22';

SELECT 
    d.ID_Documento,
    td.Nome AS Tipo_Documento,
    d.Descricao,
    d.Data_Criacao,
    d.Data_Emissao,
    d.Formato,
    p.Estado_Atual AS Estado_Processo,
    uo.Nome AS Unidade_Organizacional
FROM 
    DOCUMENTO d
JOIN 
    TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
JOIN 
    PROCESSO p ON d.ID_Processo = p.ID_Processo
LEFT JOIN 
    DOCUMENTO_UO dou ON d.ID_Documento = dou.ID_Documento
LEFT JOIN 
    UNIDADE_ORGANICA uo ON dou.ID_UO = uo.ID_UO
WHERE 
    CAST(d.Data_Criacao AS DATE) = @DataEntrada1
ORDER BY 
    d.Data_Criacao;

-- Listagem do Log completo para um determinado dia
DECLARE @DataLog DATE = '2025-01-10'; 

SELECT 
    la.ID_Log,
    la.Data_Hora,
    la.Tipo_Acao,
    la.Descricao,
    la.Estado_Acao,
    la.IP_Utilizador,
    u.Nome AS Nome_Utilizador,
    d.ID_Documento,
    td.Nome AS Tipo_Documento,
    d.Descricao AS Descricao_Documento,
    uo.Nome AS Unidade_Organizacional
FROM 
    LOG_ATIVIDADE la
LEFT JOIN 
    UTILIZADOR u ON la.ID_Utilizador = u.ID_Utilizador
LEFT JOIN 
    DOCUMENTO d ON la.ID_Documento = d.ID_Documento
LEFT JOIN 
    TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
LEFT JOIN 
    DOCUMENTO_UO dou ON d.ID_Documento = dou.ID_Documento
LEFT JOIN 
    UNIDADE_ORGANICA uo ON dou.ID_UO = uo.ID_UO
WHERE 
    CAST(la.Data_Hora AS DATE) = @DataLog
ORDER BY 
    la.Data_Hora ASC;

-- Listagem de todas as notificações associadas a um documento específico
DECLARE @ID_Documento1 INT = 1; -- Substituir 1 pelo ID do documento desejado

SELECT 
    d.ID_Documento,
    d.Descricao AS Descricao_Documento,
    p.ID_Processo,
    n.ID_Notificacao,
    n.Data_Envio,
    n.Estado_Envio,
    n.Conteudo,
    n.Tipo_Notificacao,
    n.Data_Leitura,
    u.Nome AS Nome_Destinatario
FROM 
    DOCUMENTO d
JOIN 
    PROCESSO p ON d.ID_Processo = p.ID_Processo
JOIN 
    NOTIFICACAO n ON p.ID_Processo = n.ID_Processo
LEFT JOIN 
    UTILIZADOR u ON n.ID_Utilizador_Destino = u.ID_Utilizador
WHERE 
    d.ID_Documento = @ID_Documento1
ORDER BY 
    n.Data_Envio DESC;

-- Listagem de todas as notificações associadas a uma mudança de estado
DECLARE @Acao NVARCHAR(50) = 'Mudança de Estado'; -- Substituir pelo tipo de ação desejada

SELECT 
    la.ID_Log,
    la.Data_Hora AS Data_Mudanca_Estado,
    la.Descricao AS Descricao_Mudanca_Estado,
    d.ID_Documento,
    d.Descricao AS Descricao_Documento,
    p.ID_Processo,
    p.Estado_Atual AS Estado_Atual_Processo,
    n.ID_Notificacao,
    n.Data_Envio AS Data_Envio_Notificacao,
    n.Estado_Envio AS Estado_Envio_Notificacao,
    n.Conteudo AS Conteudo_Notificacao,
    n.Tipo_Notificacao,
    u.Nome AS Nome_Destinatario
FROM 
    LOG_ATIVIDADE la
JOIN 
    DOCUMENTO d ON la.ID_Documento = d.ID_Documento
JOIN 
    PROCESSO p ON d.ID_Processo = p.ID_Processo
LEFT JOIN 
    NOTIFICACAO n ON p.ID_Processo = n.ID_Processo
LEFT JOIN 
    UTILIZADOR u ON n.ID_Utilizador_Destino = u.ID_Utilizador
WHERE 
    la.Tipo_Acao = 'Criação'
    AND n.ID_Notificacao IS NOT NULL  -- Garante que apenas notificações associadas sejam incluídas
ORDER BY 
    la.Data_Hora DESC, n.Data_Envio DESC;

END TRY
BEGIN CATCH 
    SELECT ERROR_NUMBER() AS ErrorNumber
    ,ERROR_SEVERITY() AS ErrorSeverity
    ,ERROR_STATE() AS ErrorState
    ,ERROR_PROCEDURE() AS ErrorProcedure
    ,ERROR_LINE() AS ErrorLine
    ,ERROR_MESSAGE() AS ErrorMessage;
    ROLLBACK TRANSACTION;
    PRINT 'Erro encontrado: ' + ERROR_MESSAGE();
END CATCH;

-- Parte 3--
-- Views
-- View para mostrar documentos em estado Arquivado
GO
CREATE VIEW vw_DocumentosArquivados AS
SELECT 
    d.ID_Documento,
    td.Nome AS TipoDocumento,
    d.Descricao,
    d.Data_Criacao,
    d.Data_Emissao,
    d.Data_Insercao,
    p.Data_Inicio AS Data_Inicio_Processo,
    p.Prazo AS Prazo_Processo
FROM 
    DOCUMENTO d
    JOIN TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
    JOIN ESTADO_DOCUMENTO ed ON d.ID_Estado = ed.ID_Estado
    JOIN PROCESSO p ON d.ID_Processo = p.ID_Processo
WHERE 
    ed.Nome = 'Arquivado';
GO

SELECT * FROM vw_DocumentosArquivados

-- View para mostrar documentos inseridos nos ultimos 30 dias 
GO
CREATE VIEW vw_DocumentosRecentes AS
SELECT 
    d.ID_Documento,
    td.Nome AS TipoDocumento,
    d.Descricao,
    d.Data_Criacao,
    d.Data_Emissao,
    d.Data_Insercao,
    ed.Nome AS EstadoAtual,
    p.Data_Inicio AS Data_Inicio_Processo,
    p.Prazo AS Prazo_Processo
FROM 
    DOCUMENTO d
    JOIN TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
    JOIN ESTADO_DOCUMENTO ed ON d.ID_Estado = ed.ID_Estado
    JOIN PROCESSO p ON d.ID_Processo = p.ID_Processo
WHERE 
    d.Data_Insercao >= DATEADD(DAY, -30, GETDATE());
GO

SELECT * FROM vw_DocumentosRecentes

-- View para mostrar apenas documentos do tipo Certidão de Nascimento
GO
CREATE VIEW vw_CertidoesNascimento AS
SELECT 
    d.ID_Documento,
    td.Nome AS Tipo_Documento,
    d.Descricao,
    d.Data_Criacao,
    d.Data_Emissao,
    d.Formato,
    ed.Nome AS Estado_Documento,
    uo.Nome AS Unidade_Organizacional
FROM 
    DOCUMENTO d
JOIN 
    TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
JOIN 
    ESTADO_DOCUMENTO ed ON d.ID_Estado = ed.ID_Estado
JOIN 
    DOCUMENTO_UO dou ON d.ID_Documento = dou.ID_Documento
JOIN 
    UNIDADE_ORGANICA uo ON dou.ID_UO = uo.ID_UO
WHERE 
    td.Nome = 'Certidão';
GO

SELECT * FROM vw_CertidoesNascimento;

-- View para mostrar documentos atualmente a cargo do Departamento Financeiro
GO
CREATE VIEW vw_DocumentosDepartamentoFinanceiro AS
SELECT 
    d.ID_Documento,
    td.Nome AS Tipo_Documento,
    d.Descricao,
    d.Data_Criacao,
    d.Data_Emissao,
    d.Formato,
    ed.Nome AS Estado_Documento,
    uo.Nome AS Unidade_Organizacional
FROM 
    DOCUMENTO d
JOIN 
    TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
JOIN 
    ESTADO_DOCUMENTO ed ON d.ID_Estado = ed.ID_Estado
JOIN 
    DOCUMENTO_UO dou ON d.ID_Documento = dou.ID_Documento
JOIN 
    UNIDADE_ORGANICA uo ON dou.ID_UO = uo.ID_UO
WHERE 
    uo.Nome = 'Departamento Financeiro';
GO

SELECT * FROM vw_DocumentosDepartamentoFinanceiro;

-- Funções / Procedimentos 
-- Função para obter o histórico completo de um documento
GO
CREATE FUNCTION fn_HistoricoDocumento (@ID_Documento INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        la.Data_Hora,
        la.Tipo_Acao,
        la.Descricao AS Descricao_Acao,
        la.Estado_Acao,
        u.Nome AS Usuario_Responsavel,
        p.Estado_Atual AS Estado_Processo,
        p.Estado_Aprovacao
    FROM 
        LOG_ATIVIDADE la
    JOIN 
        UTILIZADOR u ON la.ID_Utilizador = u.ID_Utilizador
    JOIN 
        PROCESSO p ON la.ID_Documento = p.ID_Documento
    WHERE 
        p.ID_Documento = @ID_Documento
);
GO

SELECT * FROM fn_HistoricoDocumento(1);

-- Função para obter o último estado de um documento
GO
CREATE FUNCTION fn_UltimoEstadoDocumento (@ID_Documento INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        la.Estado_Acao AS Ultimo_Estado,
        la.Data_Hora AS Data_Ultima_Atualizacao
    FROM 
        LOG_ATIVIDADE la
    ORDER BY 
        la.Data_Hora DESC
);
GO

SELECT * FROM fn_UltimoEstadoDocumento(1);

-- Função para obter a contagem de documentos por estado
GO
CREATE FUNCTION fn_ContagemDocumentosPorEstado ()
RETURNS TABLE
AS
RETURN
(
    SELECT 
        ed.Nome AS Estado_Documento,
        COUNT(d.ID_Documento) AS Total_Documentos
    FROM 
        DOCUMENTO d
    JOIN 
        ESTADO_DOCUMENTO ed ON d.ID_Estado = ed.ID_Estado
    GROUP BY 
        ed.Nome
);
GO

SELECT * FROM fn_ContagemDocumentosPorEstado();

-- Procedimento para listar todos os documentos confidenciais
GO
CREATE PROCEDURE sp_ListarDocumentosConfidenciais
AS
BEGIN
    SELECT 
        d.ID_Documento,
        d.Descricao,
        d.Data_Criacao,
        d.Data_Emissao,
        td.Nome AS Tipo_Documento,
        ed.Nome AS Estado_Documento
    FROM 
        DOCUMENTO d
    JOIN 
        TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
    JOIN 
        ESTADO_DOCUMENTO ed ON d.ID_Estado = ed.ID_Estado
    WHERE 
        d.Confidencial = 1;
END
GO

EXEC sp_ListarDocumentosConfidenciais;

-- Procedimento para listar documento do Departamento Jurídico
GO
CREATE PROCEDURE sp_DocumentosDepartamentoJuridico
AS
BEGIN
    SELECT 
        d.ID_Documento,
        td.Nome AS Tipo_Documento,
        d.Descricao,
        ed.Nome AS Estado_Documento,
        d.Data_Criacao,
        d.Data_Emissao,
        uo.Nome AS Unidade_Organizacional
    FROM 
        DOCUMENTO d
    JOIN 
        TIPO_DOCUMENTO td ON d.ID_Tipo_Documento = td.ID_Tipo_Documento
    JOIN 
        ESTADO_DOCUMENTO ed ON d.ID_Estado = ed.ID_Estado
    JOIN 
        DOCUMENTO_UO dou ON d.ID_Documento = dou.ID_Documento
    JOIN 
        UNIDADE_ORGANICA uo ON dou.ID_UO = uo.ID_UO
    WHERE 
        uo.Nome = 'Departamento Jurídico'
    ORDER BY 
        d.Data_Criacao DESC;
END;
GO

EXEC sp_DocumentosDepartamentoJuridico;

-- Procedimento que devolve a contagem do número total de ações do histórico
GO
CREATE PROCEDURE sp_ContarAcoesHistoricoDocumento
    @ID_Documento INT
AS
BEGIN
    SELECT 
        COUNT(*) AS Total_Acoes
    FROM 
        LOG_ATIVIDADE la
    WHERE 
        la.ID_Documento = @ID_Documento;
END
GO

EXEC sp_ContarAcoesHistoricoDocumento 1;

-- Triggers
-- Trigger para marcar documentos como Hiden em vez de deletá-los
GO
CREATE TRIGGER trg_HidentDeleteDocumento
ON DOCUMENTO
INSTEAD OF DELETE
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        UPDATE d
        SET Hiden = 1
        FROM DOCUMENTO d
        JOIN DELETED del ON d.ID_Documento = del.ID_Documento;

        INSERT INTO LOG_ATIVIDADE (ID_Utilizador, ID_Documento, Tipo_Acao, Data_Hora, Descricao, Estado_Acao)
        SELECT 
            NULL, -- Substituir por ID do usuário se estiver disponível
            del.ID_Documento,
            'Remoção Lógica',
            GETDATE(),
            CONCAT('Documento ', del.ID_Documento, ' marcado como hiden.'),
            'Sucesso'
        FROM DELETED del;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- Trigger para registar no histórico sempre que um documento for inserido ou alterado
GO
CREATE TRIGGER trg_LogDocumentoMudancas
ON DOCUMENTO
AFTER INSERT, UPDATE
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Data_Hora DATETIME = GETDATE();

        -- Inserir no histórico para cada documento inserido ou atualizado
        INSERT INTO LOG_ATIVIDADE (ID_Utilizador, ID_Documento, Tipo_Acao, Data_Hora, Descricao, Estado_Acao)
        SELECT 
            NULL, -- Substitua por ID do usuário se estiver disponível
            i.ID_Documento,
            CASE 
                WHEN NOT EXISTS (SELECT 1 FROM DELETED d WHERE d.ID_Documento = i.ID_Documento)
                THEN 'Inserção'
                ELSE 'Atualização'
            END,
            @Data_Hora,
            CONCAT('Documento ', i.ID_Documento, ' foi ', 
                CASE 
                    WHEN NOT EXISTS (SELECT 1 FROM DELETED d WHERE d.ID_Documento = i.ID_Documento)
                    THEN 'inserido'
                    ELSE 'atualizado'
                END, 
                ' com os dados atuais: ', 
                'Descrição: ', i.Descricao, ', ',
                'Data Criação: ', CONVERT(NVARCHAR, i.Data_Criacao, 120), ', ',
                'Data Emissão: ', CONVERT(NVARCHAR, i.Data_Emissao, 120), '.'),
            'Sucesso'
        FROM INSERTED i;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
-- Mecanismo inspirado em blockchain, onde cada registro no log de atividades é encadeado ao anterior através de um hash

ALTER TABLE LOG_ATIVIDADE
ADD Hash NVARCHAR(256);

GO
CREATE TRIGGER trg_BlockchainLog
ON DOCUMENTO
AFTER INSERT, UPDATE
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Data_Hora DATETIME = GETDATE();
        DECLARE @PreviousHash NVARCHAR(256);

        -- Obter o hash do último registro
        SELECT TOP 1 @PreviousHash = Hash
        FROM LOG_ATIVIDADE
        ORDER BY Data_Hora DESC;

        -- Se não houver registros anteriores, usar '1' 
        IF @PreviousHash IS NULL
            SET @PreviousHash = '1';

        -- Inserir no histórico para cada documento inserido ou atualizado
        INSERT INTO LOG_ATIVIDADE (ID_Utilizador, ID_Documento, Tipo_Acao, Data_Hora, Descricao, Estado_Acao, Hash)
        SELECT 
            NULL, -- Substituir por ID do usuário se estiver disponível
            i.ID_Documento,
            CASE 
                WHEN NOT EXISTS (SELECT 1 FROM DELETED d WHERE d.ID_Documento = i.ID_Documento)
                THEN 'Inserção'
                ELSE 'Atualização'
            END,
            @Data_Hora,
            CONCAT('Documento ', i.ID_Documento, ' foi ', 
                CASE 
                    WHEN NOT EXISTS (SELECT 1 FROM DELETED d WHERE d.ID_Documento = i.ID_Documento)
                    THEN 'inserido'
                    ELSE 'atualizado'
                END, 
                ' com os dados atuais: ', 
                'Descrição: ', i.Descricao, ', ',
                'Data Criação: ', CONVERT(NVARCHAR, i.Data_Criacao, 120), ', ',
                'Data Emissão: ', CONVERT(NVARCHAR, i.Data_Emissao, 120), '.'),
            'Sucesso',
            HASHBYTES('SHA2_256', CONCAT(i.ID_Documento, @PreviousHash, @Data_Hora)) -- Calcular o hash
        FROM INSERTED i;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO