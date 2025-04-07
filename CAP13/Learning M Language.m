let
    Fonte = Csv.Document(File.Contents("D:\Documentos\Estudos\Dados\DSA\DataScienceAcademy_PowerBI_Course\DataScienceAcademy_PowerBI_Course\CAP13\Clientes.csv"),[Delimiter=",", Columns=10, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Cabeçalhos Promovidos" = Table.PromoteHeaders(Fonte, [PromoteAllScalars=true]),
    #"Tipo Alterado" = Table.TransformColumnTypes(#"Cabeçalhos Promovidos",{{"ID_Cliente", type text}, {"Idade", type text}, {"Peso", Int64.Type}, {"Altura", Int64.Type}, 
    {"Estado Civil", type text}, {"Estado", type text}, {"Limite de Credito", Int64.Type}, {"Valor Desconto", Int64.Type}, {"Valor Compra", Int64.Type}, {"Tipo de Cliente", type text}}),
    
    //made by me
    #"Valor Substituido" = Table.ReplaceValue(#"Tipo Alterado", "?", "45", Replacer.ReplaceText,{"Idade"}),
    
    #"Tipo Ajustado" = Table.TransformColumnTypes(#"Valor Substituido", {{"Idade", Int64.Type}}),

    #"Coluna Removida" = Table.RemoveColumns(#"Tipo Ajustado",("Estado Civil")),

    #"Coluna Adicionada" = Table.AddColumn(#"Coluna Removida", "Valor Final", each[Valor Compra] - [Valor Desconto]),

    #"Dividir Coluna Pela Posição" = Table.SplitColumn(#"Coluna Adicionada", "ID_Cliente", Splitter.SplitTextByPositions({0,4}, false),
     {"ID_Cliente1", "ID_Cliente2"}),
    #"Coluna Dividida" = Table.TransformColumnTypes(#"Dividir Coluna Pela Posição", {{"ID_Cliente1", type text}, {"ID_Cliente2", Int64.Type}}),

    #"Colunas Renomeadas" = Table.RenameColumns(#"Coluna Dividida",{{"ID_Cliente1", "Codigo"}, {"ID_Cliente2", "ID"}}),

    #"Coluna Condicional Adicionada" = Table.AddColumn(#"Colunas Renomeadas", "% Desconto Especial", each if [Tipo de Cliente] = "Bronze" then 5
    else if [Tipo de Cliente] = "Prata" then 10 else if [Tipo de Cliente] = "Ouro" then 15 else if [Tipo de Cliente] = "Diamante" then 20 else 0),

    #"Logaritmo de Base 10 Calculado" = Table.TransformColumns(#"Coluna Condicional Adicionada", {{"Limite de Credito", Number.Log10, type number}})

in
    #"Logaritmo de Base 10 Calculado"