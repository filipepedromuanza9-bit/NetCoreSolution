using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;

namespace SistamaVendasMercado
{
    class Conexao
    {
        public static string stringConexao=@"Server=MUANZAII;Database=SistemaVendasMercado;Integrated Security=True ;";
         public static SqlConnection ObterConexao()
        {
            return new SqlConnection(stringConexao);
        }
           

    }
}
