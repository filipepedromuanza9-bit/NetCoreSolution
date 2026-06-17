using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Data.SqlClient;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SistamaVendasMercado
{
    public partial class Form1 : Form
    {
        public static int FuncionarioID;
        public static string NomeFuncionario;
        public static string Role;
        public Form1()
        {
            InitializeComponent();
        }

        private void btnEntrar_Click(object sender, EventArgs e)
        {
            using (SqlConnection con = Conexao.ObterConexao())
            {
                SqlCommand cmd = new SqlCommand("sp_Login", con);
                cmd.CommandType = System.Data.CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@Username", txtUser.Text);
                cmd.Parameters.AddWithValue("@Senha", txtSenha.Text);

                con.Open();
                SqlDataReader dr = cmd.ExecuteReader();

                if (dr.Read())
                {
                    FuncionarioID = Convert.ToInt32(dr["FuncionarioID"]);
                    NomeFuncionario = dr["Nome"].ToString();
                    Role = dr["NomeRole"].ToString();

                    MenuPrincipal menu = new MenuPrincipal();
                    this.Hide();
                    menu.Show();
                }
                else
                {
                    lblErro.Text = "Usuário ou senha inválidos";
                }
            }
        }
    }
}