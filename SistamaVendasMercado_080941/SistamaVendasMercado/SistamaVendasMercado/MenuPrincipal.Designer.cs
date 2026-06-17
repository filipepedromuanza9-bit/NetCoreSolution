namespace SistamaVendasMercado
{
    partial class MenuPrincipal
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.panel1 = new System.Windows.Forms.Panel();
            this.btnBuscarVenda = new System.Windows.Forms.Button();
            this.btnRelatorio = new System.Windows.Forms.Button();
            this.btnCadastroCliente = new System.Windows.Forms.Button();
            this.btnVendas = new System.Windows.Forms.Button();
            this.btnCadastroProd = new System.Windows.Forms.Button();
            this.btnCadastroFunc = new System.Windows.Forms.Button();
            this.panel1.SuspendLayout();
            this.SuspendLayout();
            // 
            // panel1
            // 
            this.panel1.BackColor = System.Drawing.Color.RoyalBlue;
            this.panel1.Controls.Add(this.btnBuscarVenda);
            this.panel1.Controls.Add(this.btnRelatorio);
            this.panel1.Controls.Add(this.btnCadastroCliente);
            this.panel1.Controls.Add(this.btnVendas);
            this.panel1.Controls.Add(this.btnCadastroProd);
            this.panel1.Controls.Add(this.btnCadastroFunc);
            this.panel1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.panel1.Location = new System.Drawing.Point(0, 0);
            this.panel1.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.panel1.Name = "panel1";
            this.panel1.Size = new System.Drawing.Size(1004, 663);
            this.panel1.TabIndex = 0;
            this.panel1.Paint += new System.Windows.Forms.PaintEventHandler(this.panel1_Paint);
            // 
            // btnBuscarVenda
            // 
            this.btnBuscarVenda.BackColor = System.Drawing.Color.Olive;
            this.btnBuscarVenda.Dock = System.Windows.Forms.DockStyle.Right;
            this.btnBuscarVenda.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))), System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnBuscarVenda.Location = new System.Drawing.Point(79, 0);
            this.btnBuscarVenda.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnBuscarVenda.Name = "btnBuscarVenda";
            this.btnBuscarVenda.Size = new System.Drawing.Size(165, 663);
            this.btnBuscarVenda.TabIndex = 7;
            this.btnBuscarVenda.Text = "BUSCARS  VENDAS";
            this.btnBuscarVenda.UseVisualStyleBackColor = false;
            this.btnBuscarVenda.Click += new System.EventHandler(this.btnDetalhesVenda_Click);
            // 
            // btnRelatorio
            // 
            this.btnRelatorio.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(128)))), ((int)(((byte)(128)))), ((int)(((byte)(255)))));
            this.btnRelatorio.Dock = System.Windows.Forms.DockStyle.Right;
            this.btnRelatorio.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))), System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnRelatorio.ForeColor = System.Drawing.Color.PeachPuff;
            this.btnRelatorio.Location = new System.Drawing.Point(244, 0);
            this.btnRelatorio.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnRelatorio.Name = "btnRelatorio";
            this.btnRelatorio.Size = new System.Drawing.Size(152, 663);
            this.btnRelatorio.TabIndex = 6;
            this.btnRelatorio.Text = "RELATORIO DE VENDAS";
            this.btnRelatorio.UseVisualStyleBackColor = false;
            this.btnRelatorio.Click += new System.EventHandler(this.btnRelatorio_Click);
            // 
            // btnCadastroCliente
            // 
            this.btnCadastroCliente.BackColor = System.Drawing.Color.OliveDrab;
            this.btnCadastroCliente.Dock = System.Windows.Forms.DockStyle.Right;
            this.btnCadastroCliente.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))), System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCadastroCliente.ForeColor = System.Drawing.Color.LightSkyBlue;
            this.btnCadastroCliente.Location = new System.Drawing.Point(396, 0);
            this.btnCadastroCliente.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnCadastroCliente.Name = "btnCadastroCliente";
            this.btnCadastroCliente.Size = new System.Drawing.Size(152, 663);
            this.btnCadastroCliente.TabIndex = 5;
            this.btnCadastroCliente.Text = "CADASTRO DO SCLIENTES";
            this.btnCadastroCliente.UseVisualStyleBackColor = false;
            this.btnCadastroCliente.Click += new System.EventHandler(this.btnCadastroCliente_Click);
            // 
            // btnVendas
            // 
            this.btnVendas.BackColor = System.Drawing.Color.FromArgb(((int)(((byte)(64)))), ((int)(((byte)(64)))), ((int)(((byte)(0)))));
            this.btnVendas.Dock = System.Windows.Forms.DockStyle.Right;
            this.btnVendas.Font = new System.Drawing.Font("Microsoft Sans Serif", 14.25F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))), System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnVendas.ForeColor = System.Drawing.Color.PeachPuff;
            this.btnVendas.Location = new System.Drawing.Point(548, 0);
            this.btnVendas.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnVendas.Name = "btnVendas";
            this.btnVendas.Size = new System.Drawing.Size(152, 663);
            this.btnVendas.TabIndex = 2;
            this.btnVendas.Text = "VENDAS";
            this.btnVendas.UseVisualStyleBackColor = false;
            this.btnVendas.Click += new System.EventHandler(this.btnVendas_Click);
            // 
            // btnCadastroProd
            // 
            this.btnCadastroProd.BackColor = System.Drawing.Color.Olive;
            this.btnCadastroProd.Dock = System.Windows.Forms.DockStyle.Right;
            this.btnCadastroProd.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))), System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCadastroProd.Location = new System.Drawing.Point(700, 0);
            this.btnCadastroProd.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnCadastroProd.Name = "btnCadastroProd";
            this.btnCadastroProd.Size = new System.Drawing.Size(152, 663);
            this.btnCadastroProd.TabIndex = 1;
            this.btnCadastroProd.Text = "CADASTRO DOS PRODUTOS";
            this.btnCadastroProd.UseVisualStyleBackColor = false;
            this.btnCadastroProd.Click += new System.EventHandler(this.btnCadastroProd_Click);
            // 
            // btnCadastroFunc
            // 
            this.btnCadastroFunc.BackColor = System.Drawing.Color.OliveDrab;
            this.btnCadastroFunc.Dock = System.Windows.Forms.DockStyle.Right;
            this.btnCadastroFunc.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, ((System.Drawing.FontStyle)((System.Drawing.FontStyle.Bold | System.Drawing.FontStyle.Italic))), System.Drawing.GraphicsUnit.Point, ((byte)(0)));
            this.btnCadastroFunc.ForeColor = System.Drawing.Color.DarkSlateGray;
            this.btnCadastroFunc.Location = new System.Drawing.Point(852, 0);
            this.btnCadastroFunc.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.btnCadastroFunc.Name = "btnCadastroFunc";
            this.btnCadastroFunc.Size = new System.Drawing.Size(152, 663);
            this.btnCadastroFunc.TabIndex = 0;
            this.btnCadastroFunc.Text = "CADASTRO DOS FUNCIONARIOS";
            this.btnCadastroFunc.UseVisualStyleBackColor = false;
            this.btnCadastroFunc.Click += new System.EventHandler(this.btnCadastroFunc_Click);
            // 
            // MenuPrincipal
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(8F, 16F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1004, 663);
            this.Controls.Add(this.panel1);
            this.Margin = new System.Windows.Forms.Padding(4, 4, 4, 4);
            this.Name = "MenuPrincipal";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.Load += new System.EventHandler(this.MenuPrincipal_Load);
            this.panel1.ResumeLayout(false);
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.Panel panel1;
        private System.Windows.Forms.Button btnVendas;
        private System.Windows.Forms.Button btnCadastroProd;
        private System.Windows.Forms.Button btnCadastroFunc;
        private System.Windows.Forms.Button btnRelatorio;
        private System.Windows.Forms.Button btnCadastroCliente;
        private System.Windows.Forms.Button btnBuscarVenda;
    }
}