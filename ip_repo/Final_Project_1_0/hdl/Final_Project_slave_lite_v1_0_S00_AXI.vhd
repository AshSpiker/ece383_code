library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Final_Project_slave_lite_v1_0_S00_AXI is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXI data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- Width of S_AXI address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 11
	);
	port (
		-- Users to add ports here

		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
	);
end Final_Project_slave_lite_v1_0_S00_AXI;

architecture arch_imp of Final_Project_slave_lite_v1_0_S00_AXI is

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 8;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 512
	signal slv_reg0	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg1	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg3	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg4	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg5	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg6	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg7	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg8	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg9	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg10	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg11	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg12	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg13	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg14	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg15	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg16	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg17	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg18	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg19	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg20	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg21	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg22	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg23	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg24	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg25	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg26	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg27	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg28	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg29	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg30	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg31	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg32	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg33	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg34	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg35	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg36	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg37	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg38	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg39	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg40	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg41	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg42	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg43	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg44	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg45	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg46	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg47	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg48	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg49	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg50	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg51	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg52	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg53	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg54	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg55	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg56	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg57	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg58	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg59	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg60	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg61	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg62	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg63	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg64	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg65	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg66	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg67	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg68	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg69	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg70	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg71	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg72	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg73	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg74	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg75	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg76	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg77	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg78	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg79	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg80	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg81	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg82	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg83	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg84	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg85	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg86	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg87	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg88	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg89	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg90	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg91	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg92	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg93	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg94	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg95	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg96	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg97	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg98	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg99	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg100	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg101	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg102	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg103	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg104	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg105	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg106	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg107	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg108	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg109	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg110	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg111	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg112	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg113	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg114	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg115	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg116	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg117	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg118	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg119	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg120	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg121	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg122	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg123	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg124	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg125	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg126	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg127	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg128	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg129	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg130	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg131	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg132	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg133	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg134	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg135	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg136	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg137	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg138	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg139	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg140	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg141	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg142	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg143	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg144	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg145	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg146	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg147	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg148	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg149	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg150	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg151	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg152	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg153	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg154	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg155	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg156	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg157	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg158	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg159	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg160	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg161	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg162	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg163	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg164	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg165	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg166	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg167	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg168	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg169	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg170	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg171	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg172	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg173	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg174	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg175	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg176	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg177	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg178	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg179	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg180	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg181	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg182	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg183	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg184	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg185	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg186	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg187	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg188	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg189	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg190	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg191	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg192	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg193	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg194	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg195	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg196	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg197	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg198	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg199	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg200	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg201	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg202	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg203	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg204	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg205	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg206	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg207	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg208	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg209	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg210	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg211	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg212	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg213	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg214	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg215	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg216	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg217	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg218	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg219	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg220	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg221	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg222	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg223	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg224	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg225	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg226	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg227	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg228	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg229	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg230	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg231	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg232	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg233	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg234	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg235	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg236	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg237	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg238	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg239	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg240	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg241	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg242	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg243	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg244	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg245	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg246	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg247	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg248	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg249	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg250	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg251	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg252	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg253	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg254	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg255	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg256	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg257	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg258	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg259	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg260	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg261	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg262	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg263	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg264	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg265	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg266	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg267	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg268	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg269	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg270	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg271	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg272	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg273	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg274	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg275	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg276	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg277	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg278	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg279	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg280	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg281	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg282	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg283	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg284	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg285	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg286	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg287	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg288	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg289	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg290	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg291	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg292	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg293	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg294	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg295	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg296	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg297	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg298	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg299	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg300	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg301	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg302	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg303	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg304	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg305	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg306	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg307	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg308	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg309	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg310	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg311	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg312	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg313	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg314	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg315	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg316	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg317	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg318	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg319	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg320	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg321	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg322	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg323	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg324	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg325	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg326	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg327	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg328	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg329	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg330	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg331	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg332	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg333	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg334	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg335	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg336	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg337	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg338	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg339	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg340	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg341	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg342	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg343	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg344	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg345	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg346	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg347	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg348	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg349	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg350	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg351	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg352	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg353	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg354	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg355	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg356	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg357	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg358	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg359	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg360	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg361	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg362	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg363	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg364	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg365	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg366	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg367	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg368	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg369	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg370	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg371	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg372	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg373	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg374	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg375	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg376	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg377	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg378	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg379	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg380	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg381	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg382	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg383	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg384	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg385	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg386	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg387	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg388	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg389	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg390	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg391	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg392	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg393	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg394	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg395	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg396	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg397	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg398	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg399	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg400	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg401	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg402	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg403	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg404	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg405	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg406	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg407	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg408	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg409	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg410	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg411	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg412	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg413	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg414	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg415	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg416	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg417	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg418	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg419	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg420	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg421	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg422	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg423	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg424	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg425	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg426	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg427	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg428	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg429	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg430	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg431	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg432	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg433	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg434	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg435	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg436	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg437	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg438	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg439	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg440	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg441	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg442	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg443	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg444	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg445	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg446	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg447	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg448	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg449	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg450	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg451	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg452	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg453	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg454	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg455	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg456	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg457	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg458	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg459	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg460	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg461	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg462	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg463	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg464	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg465	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg466	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg467	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg468	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg469	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg470	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg471	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg472	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg473	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg474	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg475	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg476	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg477	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg478	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg479	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg480	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg481	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg482	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg483	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg484	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg485	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg486	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg487	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg488	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg489	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg490	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg491	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg492	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg493	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg494	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg495	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg496	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg497	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg498	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg499	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg500	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg501	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg502	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg503	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg504	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg505	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg506	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg507	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg508	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg509	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg510	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg511	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;

	 signal mem_logic  : std_logic_vector(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);

	 --State machine local parameters
	constant Idle : std_logic_vector(1 downto 0) := "00";
	constant Raddr: std_logic_vector(1 downto 0) := "10";
	constant Rdata: std_logic_vector(1 downto 0) := "11";
	constant Waddr: std_logic_vector(1 downto 0) := "10";
	constant Wdata: std_logic_vector(1 downto 0) := "11";
	 --State machine variables
	signal state_read : std_logic_vector(1 downto 0);
	signal state_write: std_logic_vector(1 downto 0); 
begin
	-- I/O Connections assignments

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
	    mem_logic     <= S_AXI_AWADDR(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) when (S_AXI_AWVALID = '1') else axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);

	-- Implement Write state machine
	-- Outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
	 process (S_AXI_ACLK)                                       
	   begin                                       
	     if rising_edge(S_AXI_ACLK) then                                       
	        if S_AXI_ARESETN = '0' then                                       
	          --asserting initial values to all 0's during reset                                       
	          axi_awready <= '0';                                       
	          axi_wready <= '0';                                       
	          axi_bvalid <= '0';                                       
	          axi_bresp <= (others => '0');                                       
	          state_write <= Idle;                                       
	        else                                       
	          case (state_write) is                                       
	             when Idle =>		--Initial state inidicating reset is done and ready to receive read/write transactions                                       
	               if (S_AXI_ARESETN = '1') then                                       
	                 axi_awready <= '1';                                       
	                 axi_wready <= '1';                                       
	                 state_write <= Waddr;                                       
	               else state_write <= state_write;                                       
	               end if;                                       
	             when Waddr =>		--At this state, slave is ready to receive address along with corresponding control signals and first data packet. Response valid is also handled at this state                                       
	               if (S_AXI_AWVALID = '1' and axi_awready = '1') then                                       
	                 axi_awaddr <= S_AXI_AWADDR;                                       
	                 if (S_AXI_WVALID = '1') then                                       
	                   axi_awready <= '1';                                       
	                   state_write <= Waddr;                                       
	                   axi_bvalid <= '1';                                       
	                 else                                       
	                   axi_awready <= '0';                                       
	                   state_write <= Wdata;                                       
	                   if (S_AXI_BREADY = '1' and axi_bvalid = '1') then                                       
	                     axi_bvalid <= '0';                                       
	                   end if;                                       
	                 end if;                                       
	               else                                        
	                 state_write <= state_write;                                       
	                 if (S_AXI_BREADY = '1' and axi_bvalid = '1') then                                       
	                   axi_bvalid <= '0';                                       
	                 end if;                                       
	               end if;                                       
	             when Wdata =>		--At this state, slave is ready to receive the data packets until the number of transfers is equal to burst length                                       
	               if (S_AXI_WVALID = '1') then                                       
	                 state_write <= Waddr;                                       
	                 axi_bvalid <= '1';                                       
	                 axi_awready <= '1';                                       
	               else                                       
	                 state_write <= state_write;                                       
	                 if (S_AXI_BREADY ='1' and axi_bvalid = '1') then                                       
	                   axi_bvalid <= '0';                                       
	                 end if;                                       
	               end if;                                       
	             when others =>      --reserved                                       
	               axi_awready <= '0';                                       
	               axi_wready <= '0';                                       
	               axi_bvalid <= '0';                                       
	           end case;                                       
	        end if;                                       
	      end if;                                                
	 end process;                                       
	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      slv_reg0 <= (others => '0');
	      slv_reg1 <= (others => '0');
	      slv_reg2 <= (others => '0');
	      slv_reg3 <= (others => '0');
	      slv_reg4 <= (others => '0');
	      slv_reg5 <= (others => '0');
	      slv_reg6 <= (others => '0');
	      slv_reg7 <= (others => '0');
	      slv_reg8 <= (others => '0');
	      slv_reg9 <= (others => '0');
	      slv_reg10 <= (others => '0');
	      slv_reg11 <= (others => '0');
	      slv_reg12 <= (others => '0');
	      slv_reg13 <= (others => '0');
	      slv_reg14 <= (others => '0');
	      slv_reg15 <= (others => '0');
	      slv_reg16 <= (others => '0');
	      slv_reg17 <= (others => '0');
	      slv_reg18 <= (others => '0');
	      slv_reg19 <= (others => '0');
	      slv_reg20 <= (others => '0');
	      slv_reg21 <= (others => '0');
	      slv_reg22 <= (others => '0');
	      slv_reg23 <= (others => '0');
	      slv_reg24 <= (others => '0');
	      slv_reg25 <= (others => '0');
	      slv_reg26 <= (others => '0');
	      slv_reg27 <= (others => '0');
	      slv_reg28 <= (others => '0');
	      slv_reg29 <= (others => '0');
	      slv_reg30 <= (others => '0');
	      slv_reg31 <= (others => '0');
	      slv_reg32 <= (others => '0');
	      slv_reg33 <= (others => '0');
	      slv_reg34 <= (others => '0');
	      slv_reg35 <= (others => '0');
	      slv_reg36 <= (others => '0');
	      slv_reg37 <= (others => '0');
	      slv_reg38 <= (others => '0');
	      slv_reg39 <= (others => '0');
	      slv_reg40 <= (others => '0');
	      slv_reg41 <= (others => '0');
	      slv_reg42 <= (others => '0');
	      slv_reg43 <= (others => '0');
	      slv_reg44 <= (others => '0');
	      slv_reg45 <= (others => '0');
	      slv_reg46 <= (others => '0');
	      slv_reg47 <= (others => '0');
	      slv_reg48 <= (others => '0');
	      slv_reg49 <= (others => '0');
	      slv_reg50 <= (others => '0');
	      slv_reg51 <= (others => '0');
	      slv_reg52 <= (others => '0');
	      slv_reg53 <= (others => '0');
	      slv_reg54 <= (others => '0');
	      slv_reg55 <= (others => '0');
	      slv_reg56 <= (others => '0');
	      slv_reg57 <= (others => '0');
	      slv_reg58 <= (others => '0');
	      slv_reg59 <= (others => '0');
	      slv_reg60 <= (others => '0');
	      slv_reg61 <= (others => '0');
	      slv_reg62 <= (others => '0');
	      slv_reg63 <= (others => '0');
	      slv_reg64 <= (others => '0');
	      slv_reg65 <= (others => '0');
	      slv_reg66 <= (others => '0');
	      slv_reg67 <= (others => '0');
	      slv_reg68 <= (others => '0');
	      slv_reg69 <= (others => '0');
	      slv_reg70 <= (others => '0');
	      slv_reg71 <= (others => '0');
	      slv_reg72 <= (others => '0');
	      slv_reg73 <= (others => '0');
	      slv_reg74 <= (others => '0');
	      slv_reg75 <= (others => '0');
	      slv_reg76 <= (others => '0');
	      slv_reg77 <= (others => '0');
	      slv_reg78 <= (others => '0');
	      slv_reg79 <= (others => '0');
	      slv_reg80 <= (others => '0');
	      slv_reg81 <= (others => '0');
	      slv_reg82 <= (others => '0');
	      slv_reg83 <= (others => '0');
	      slv_reg84 <= (others => '0');
	      slv_reg85 <= (others => '0');
	      slv_reg86 <= (others => '0');
	      slv_reg87 <= (others => '0');
	      slv_reg88 <= (others => '0');
	      slv_reg89 <= (others => '0');
	      slv_reg90 <= (others => '0');
	      slv_reg91 <= (others => '0');
	      slv_reg92 <= (others => '0');
	      slv_reg93 <= (others => '0');
	      slv_reg94 <= (others => '0');
	      slv_reg95 <= (others => '0');
	      slv_reg96 <= (others => '0');
	      slv_reg97 <= (others => '0');
	      slv_reg98 <= (others => '0');
	      slv_reg99 <= (others => '0');
	      slv_reg100 <= (others => '0');
	      slv_reg101 <= (others => '0');
	      slv_reg102 <= (others => '0');
	      slv_reg103 <= (others => '0');
	      slv_reg104 <= (others => '0');
	      slv_reg105 <= (others => '0');
	      slv_reg106 <= (others => '0');
	      slv_reg107 <= (others => '0');
	      slv_reg108 <= (others => '0');
	      slv_reg109 <= (others => '0');
	      slv_reg110 <= (others => '0');
	      slv_reg111 <= (others => '0');
	      slv_reg112 <= (others => '0');
	      slv_reg113 <= (others => '0');
	      slv_reg114 <= (others => '0');
	      slv_reg115 <= (others => '0');
	      slv_reg116 <= (others => '0');
	      slv_reg117 <= (others => '0');
	      slv_reg118 <= (others => '0');
	      slv_reg119 <= (others => '0');
	      slv_reg120 <= (others => '0');
	      slv_reg121 <= (others => '0');
	      slv_reg122 <= (others => '0');
	      slv_reg123 <= (others => '0');
	      slv_reg124 <= (others => '0');
	      slv_reg125 <= (others => '0');
	      slv_reg126 <= (others => '0');
	      slv_reg127 <= (others => '0');
	      slv_reg128 <= (others => '0');
	      slv_reg129 <= (others => '0');
	      slv_reg130 <= (others => '0');
	      slv_reg131 <= (others => '0');
	      slv_reg132 <= (others => '0');
	      slv_reg133 <= (others => '0');
	      slv_reg134 <= (others => '0');
	      slv_reg135 <= (others => '0');
	      slv_reg136 <= (others => '0');
	      slv_reg137 <= (others => '0');
	      slv_reg138 <= (others => '0');
	      slv_reg139 <= (others => '0');
	      slv_reg140 <= (others => '0');
	      slv_reg141 <= (others => '0');
	      slv_reg142 <= (others => '0');
	      slv_reg143 <= (others => '0');
	      slv_reg144 <= (others => '0');
	      slv_reg145 <= (others => '0');
	      slv_reg146 <= (others => '0');
	      slv_reg147 <= (others => '0');
	      slv_reg148 <= (others => '0');
	      slv_reg149 <= (others => '0');
	      slv_reg150 <= (others => '0');
	      slv_reg151 <= (others => '0');
	      slv_reg152 <= (others => '0');
	      slv_reg153 <= (others => '0');
	      slv_reg154 <= (others => '0');
	      slv_reg155 <= (others => '0');
	      slv_reg156 <= (others => '0');
	      slv_reg157 <= (others => '0');
	      slv_reg158 <= (others => '0');
	      slv_reg159 <= (others => '0');
	      slv_reg160 <= (others => '0');
	      slv_reg161 <= (others => '0');
	      slv_reg162 <= (others => '0');
	      slv_reg163 <= (others => '0');
	      slv_reg164 <= (others => '0');
	      slv_reg165 <= (others => '0');
	      slv_reg166 <= (others => '0');
	      slv_reg167 <= (others => '0');
	      slv_reg168 <= (others => '0');
	      slv_reg169 <= (others => '0');
	      slv_reg170 <= (others => '0');
	      slv_reg171 <= (others => '0');
	      slv_reg172 <= (others => '0');
	      slv_reg173 <= (others => '0');
	      slv_reg174 <= (others => '0');
	      slv_reg175 <= (others => '0');
	      slv_reg176 <= (others => '0');
	      slv_reg177 <= (others => '0');
	      slv_reg178 <= (others => '0');
	      slv_reg179 <= (others => '0');
	      slv_reg180 <= (others => '0');
	      slv_reg181 <= (others => '0');
	      slv_reg182 <= (others => '0');
	      slv_reg183 <= (others => '0');
	      slv_reg184 <= (others => '0');
	      slv_reg185 <= (others => '0');
	      slv_reg186 <= (others => '0');
	      slv_reg187 <= (others => '0');
	      slv_reg188 <= (others => '0');
	      slv_reg189 <= (others => '0');
	      slv_reg190 <= (others => '0');
	      slv_reg191 <= (others => '0');
	      slv_reg192 <= (others => '0');
	      slv_reg193 <= (others => '0');
	      slv_reg194 <= (others => '0');
	      slv_reg195 <= (others => '0');
	      slv_reg196 <= (others => '0');
	      slv_reg197 <= (others => '0');
	      slv_reg198 <= (others => '0');
	      slv_reg199 <= (others => '0');
	      slv_reg200 <= (others => '0');
	      slv_reg201 <= (others => '0');
	      slv_reg202 <= (others => '0');
	      slv_reg203 <= (others => '0');
	      slv_reg204 <= (others => '0');
	      slv_reg205 <= (others => '0');
	      slv_reg206 <= (others => '0');
	      slv_reg207 <= (others => '0');
	      slv_reg208 <= (others => '0');
	      slv_reg209 <= (others => '0');
	      slv_reg210 <= (others => '0');
	      slv_reg211 <= (others => '0');
	      slv_reg212 <= (others => '0');
	      slv_reg213 <= (others => '0');
	      slv_reg214 <= (others => '0');
	      slv_reg215 <= (others => '0');
	      slv_reg216 <= (others => '0');
	      slv_reg217 <= (others => '0');
	      slv_reg218 <= (others => '0');
	      slv_reg219 <= (others => '0');
	      slv_reg220 <= (others => '0');
	      slv_reg221 <= (others => '0');
	      slv_reg222 <= (others => '0');
	      slv_reg223 <= (others => '0');
	      slv_reg224 <= (others => '0');
	      slv_reg225 <= (others => '0');
	      slv_reg226 <= (others => '0');
	      slv_reg227 <= (others => '0');
	      slv_reg228 <= (others => '0');
	      slv_reg229 <= (others => '0');
	      slv_reg230 <= (others => '0');
	      slv_reg231 <= (others => '0');
	      slv_reg232 <= (others => '0');
	      slv_reg233 <= (others => '0');
	      slv_reg234 <= (others => '0');
	      slv_reg235 <= (others => '0');
	      slv_reg236 <= (others => '0');
	      slv_reg237 <= (others => '0');
	      slv_reg238 <= (others => '0');
	      slv_reg239 <= (others => '0');
	      slv_reg240 <= (others => '0');
	      slv_reg241 <= (others => '0');
	      slv_reg242 <= (others => '0');
	      slv_reg243 <= (others => '0');
	      slv_reg244 <= (others => '0');
	      slv_reg245 <= (others => '0');
	      slv_reg246 <= (others => '0');
	      slv_reg247 <= (others => '0');
	      slv_reg248 <= (others => '0');
	      slv_reg249 <= (others => '0');
	      slv_reg250 <= (others => '0');
	      slv_reg251 <= (others => '0');
	      slv_reg252 <= (others => '0');
	      slv_reg253 <= (others => '0');
	      slv_reg254 <= (others => '0');
	      slv_reg255 <= (others => '0');
	      slv_reg256 <= (others => '0');
	      slv_reg257 <= (others => '0');
	      slv_reg258 <= (others => '0');
	      slv_reg259 <= (others => '0');
	      slv_reg260 <= (others => '0');
	      slv_reg261 <= (others => '0');
	      slv_reg262 <= (others => '0');
	      slv_reg263 <= (others => '0');
	      slv_reg264 <= (others => '0');
	      slv_reg265 <= (others => '0');
	      slv_reg266 <= (others => '0');
	      slv_reg267 <= (others => '0');
	      slv_reg268 <= (others => '0');
	      slv_reg269 <= (others => '0');
	      slv_reg270 <= (others => '0');
	      slv_reg271 <= (others => '0');
	      slv_reg272 <= (others => '0');
	      slv_reg273 <= (others => '0');
	      slv_reg274 <= (others => '0');
	      slv_reg275 <= (others => '0');
	      slv_reg276 <= (others => '0');
	      slv_reg277 <= (others => '0');
	      slv_reg278 <= (others => '0');
	      slv_reg279 <= (others => '0');
	      slv_reg280 <= (others => '0');
	      slv_reg281 <= (others => '0');
	      slv_reg282 <= (others => '0');
	      slv_reg283 <= (others => '0');
	      slv_reg284 <= (others => '0');
	      slv_reg285 <= (others => '0');
	      slv_reg286 <= (others => '0');
	      slv_reg287 <= (others => '0');
	      slv_reg288 <= (others => '0');
	      slv_reg289 <= (others => '0');
	      slv_reg290 <= (others => '0');
	      slv_reg291 <= (others => '0');
	      slv_reg292 <= (others => '0');
	      slv_reg293 <= (others => '0');
	      slv_reg294 <= (others => '0');
	      slv_reg295 <= (others => '0');
	      slv_reg296 <= (others => '0');
	      slv_reg297 <= (others => '0');
	      slv_reg298 <= (others => '0');
	      slv_reg299 <= (others => '0');
	      slv_reg300 <= (others => '0');
	      slv_reg301 <= (others => '0');
	      slv_reg302 <= (others => '0');
	      slv_reg303 <= (others => '0');
	      slv_reg304 <= (others => '0');
	      slv_reg305 <= (others => '0');
	      slv_reg306 <= (others => '0');
	      slv_reg307 <= (others => '0');
	      slv_reg308 <= (others => '0');
	      slv_reg309 <= (others => '0');
	      slv_reg310 <= (others => '0');
	      slv_reg311 <= (others => '0');
	      slv_reg312 <= (others => '0');
	      slv_reg313 <= (others => '0');
	      slv_reg314 <= (others => '0');
	      slv_reg315 <= (others => '0');
	      slv_reg316 <= (others => '0');
	      slv_reg317 <= (others => '0');
	      slv_reg318 <= (others => '0');
	      slv_reg319 <= (others => '0');
	      slv_reg320 <= (others => '0');
	      slv_reg321 <= (others => '0');
	      slv_reg322 <= (others => '0');
	      slv_reg323 <= (others => '0');
	      slv_reg324 <= (others => '0');
	      slv_reg325 <= (others => '0');
	      slv_reg326 <= (others => '0');
	      slv_reg327 <= (others => '0');
	      slv_reg328 <= (others => '0');
	      slv_reg329 <= (others => '0');
	      slv_reg330 <= (others => '0');
	      slv_reg331 <= (others => '0');
	      slv_reg332 <= (others => '0');
	      slv_reg333 <= (others => '0');
	      slv_reg334 <= (others => '0');
	      slv_reg335 <= (others => '0');
	      slv_reg336 <= (others => '0');
	      slv_reg337 <= (others => '0');
	      slv_reg338 <= (others => '0');
	      slv_reg339 <= (others => '0');
	      slv_reg340 <= (others => '0');
	      slv_reg341 <= (others => '0');
	      slv_reg342 <= (others => '0');
	      slv_reg343 <= (others => '0');
	      slv_reg344 <= (others => '0');
	      slv_reg345 <= (others => '0');
	      slv_reg346 <= (others => '0');
	      slv_reg347 <= (others => '0');
	      slv_reg348 <= (others => '0');
	      slv_reg349 <= (others => '0');
	      slv_reg350 <= (others => '0');
	      slv_reg351 <= (others => '0');
	      slv_reg352 <= (others => '0');
	      slv_reg353 <= (others => '0');
	      slv_reg354 <= (others => '0');
	      slv_reg355 <= (others => '0');
	      slv_reg356 <= (others => '0');
	      slv_reg357 <= (others => '0');
	      slv_reg358 <= (others => '0');
	      slv_reg359 <= (others => '0');
	      slv_reg360 <= (others => '0');
	      slv_reg361 <= (others => '0');
	      slv_reg362 <= (others => '0');
	      slv_reg363 <= (others => '0');
	      slv_reg364 <= (others => '0');
	      slv_reg365 <= (others => '0');
	      slv_reg366 <= (others => '0');
	      slv_reg367 <= (others => '0');
	      slv_reg368 <= (others => '0');
	      slv_reg369 <= (others => '0');
	      slv_reg370 <= (others => '0');
	      slv_reg371 <= (others => '0');
	      slv_reg372 <= (others => '0');
	      slv_reg373 <= (others => '0');
	      slv_reg374 <= (others => '0');
	      slv_reg375 <= (others => '0');
	      slv_reg376 <= (others => '0');
	      slv_reg377 <= (others => '0');
	      slv_reg378 <= (others => '0');
	      slv_reg379 <= (others => '0');
	      slv_reg380 <= (others => '0');
	      slv_reg381 <= (others => '0');
	      slv_reg382 <= (others => '0');
	      slv_reg383 <= (others => '0');
	      slv_reg384 <= (others => '0');
	      slv_reg385 <= (others => '0');
	      slv_reg386 <= (others => '0');
	      slv_reg387 <= (others => '0');
	      slv_reg388 <= (others => '0');
	      slv_reg389 <= (others => '0');
	      slv_reg390 <= (others => '0');
	      slv_reg391 <= (others => '0');
	      slv_reg392 <= (others => '0');
	      slv_reg393 <= (others => '0');
	      slv_reg394 <= (others => '0');
	      slv_reg395 <= (others => '0');
	      slv_reg396 <= (others => '0');
	      slv_reg397 <= (others => '0');
	      slv_reg398 <= (others => '0');
	      slv_reg399 <= (others => '0');
	      slv_reg400 <= (others => '0');
	      slv_reg401 <= (others => '0');
	      slv_reg402 <= (others => '0');
	      slv_reg403 <= (others => '0');
	      slv_reg404 <= (others => '0');
	      slv_reg405 <= (others => '0');
	      slv_reg406 <= (others => '0');
	      slv_reg407 <= (others => '0');
	      slv_reg408 <= (others => '0');
	      slv_reg409 <= (others => '0');
	      slv_reg410 <= (others => '0');
	      slv_reg411 <= (others => '0');
	      slv_reg412 <= (others => '0');
	      slv_reg413 <= (others => '0');
	      slv_reg414 <= (others => '0');
	      slv_reg415 <= (others => '0');
	      slv_reg416 <= (others => '0');
	      slv_reg417 <= (others => '0');
	      slv_reg418 <= (others => '0');
	      slv_reg419 <= (others => '0');
	      slv_reg420 <= (others => '0');
	      slv_reg421 <= (others => '0');
	      slv_reg422 <= (others => '0');
	      slv_reg423 <= (others => '0');
	      slv_reg424 <= (others => '0');
	      slv_reg425 <= (others => '0');
	      slv_reg426 <= (others => '0');
	      slv_reg427 <= (others => '0');
	      slv_reg428 <= (others => '0');
	      slv_reg429 <= (others => '0');
	      slv_reg430 <= (others => '0');
	      slv_reg431 <= (others => '0');
	      slv_reg432 <= (others => '0');
	      slv_reg433 <= (others => '0');
	      slv_reg434 <= (others => '0');
	      slv_reg435 <= (others => '0');
	      slv_reg436 <= (others => '0');
	      slv_reg437 <= (others => '0');
	      slv_reg438 <= (others => '0');
	      slv_reg439 <= (others => '0');
	      slv_reg440 <= (others => '0');
	      slv_reg441 <= (others => '0');
	      slv_reg442 <= (others => '0');
	      slv_reg443 <= (others => '0');
	      slv_reg444 <= (others => '0');
	      slv_reg445 <= (others => '0');
	      slv_reg446 <= (others => '0');
	      slv_reg447 <= (others => '0');
	      slv_reg448 <= (others => '0');
	      slv_reg449 <= (others => '0');
	      slv_reg450 <= (others => '0');
	      slv_reg451 <= (others => '0');
	      slv_reg452 <= (others => '0');
	      slv_reg453 <= (others => '0');
	      slv_reg454 <= (others => '0');
	      slv_reg455 <= (others => '0');
	      slv_reg456 <= (others => '0');
	      slv_reg457 <= (others => '0');
	      slv_reg458 <= (others => '0');
	      slv_reg459 <= (others => '0');
	      slv_reg460 <= (others => '0');
	      slv_reg461 <= (others => '0');
	      slv_reg462 <= (others => '0');
	      slv_reg463 <= (others => '0');
	      slv_reg464 <= (others => '0');
	      slv_reg465 <= (others => '0');
	      slv_reg466 <= (others => '0');
	      slv_reg467 <= (others => '0');
	      slv_reg468 <= (others => '0');
	      slv_reg469 <= (others => '0');
	      slv_reg470 <= (others => '0');
	      slv_reg471 <= (others => '0');
	      slv_reg472 <= (others => '0');
	      slv_reg473 <= (others => '0');
	      slv_reg474 <= (others => '0');
	      slv_reg475 <= (others => '0');
	      slv_reg476 <= (others => '0');
	      slv_reg477 <= (others => '0');
	      slv_reg478 <= (others => '0');
	      slv_reg479 <= (others => '0');
	      slv_reg480 <= (others => '0');
	      slv_reg481 <= (others => '0');
	      slv_reg482 <= (others => '0');
	      slv_reg483 <= (others => '0');
	      slv_reg484 <= (others => '0');
	      slv_reg485 <= (others => '0');
	      slv_reg486 <= (others => '0');
	      slv_reg487 <= (others => '0');
	      slv_reg488 <= (others => '0');
	      slv_reg489 <= (others => '0');
	      slv_reg490 <= (others => '0');
	      slv_reg491 <= (others => '0');
	      slv_reg492 <= (others => '0');
	      slv_reg493 <= (others => '0');
	      slv_reg494 <= (others => '0');
	      slv_reg495 <= (others => '0');
	      slv_reg496 <= (others => '0');
	      slv_reg497 <= (others => '0');
	      slv_reg498 <= (others => '0');
	      slv_reg499 <= (others => '0');
	      slv_reg500 <= (others => '0');
	      slv_reg501 <= (others => '0');
	      slv_reg502 <= (others => '0');
	      slv_reg503 <= (others => '0');
	      slv_reg504 <= (others => '0');
	      slv_reg505 <= (others => '0');
	      slv_reg506 <= (others => '0');
	      slv_reg507 <= (others => '0');
	      slv_reg508 <= (others => '0');
	      slv_reg509 <= (others => '0');
	      slv_reg510 <= (others => '0');
	      slv_reg511 <= (others => '0');
	    else
	      if (S_AXI_WVALID = '1') then
	          case (mem_logic) is
	          when b"000000000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 0
	                slv_reg0(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000000001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 1
	                slv_reg1(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000000010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 2
	                slv_reg2(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000000011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 3
	                slv_reg3(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000000100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 4
	                slv_reg4(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000000101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 5
	                slv_reg5(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000000110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                slv_reg6(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000000111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 7
	                slv_reg7(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000001000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 8
	                slv_reg8(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000001001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 9
	                slv_reg9(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000001010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 10
	                slv_reg10(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000001011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 11
	                slv_reg11(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000001100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 12
	                slv_reg12(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000001101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 13
	                slv_reg13(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000001110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 14
	                slv_reg14(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000001111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 15
	                slv_reg15(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000010000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 16
	                slv_reg16(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000010001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 17
	                slv_reg17(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000010010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 18
	                slv_reg18(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000010011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 19
	                slv_reg19(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000010100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 20
	                slv_reg20(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000010101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 21
	                slv_reg21(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000010110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 22
	                slv_reg22(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000010111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 23
	                slv_reg23(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000011000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 24
	                slv_reg24(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000011001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 25
	                slv_reg25(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000011010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 26
	                slv_reg26(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000011011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 27
	                slv_reg27(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000011100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 28
	                slv_reg28(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000011101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 29
	                slv_reg29(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000011110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 30
	                slv_reg30(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000011111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 31
	                slv_reg31(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000100000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 32
	                slv_reg32(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000100001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 33
	                slv_reg33(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000100010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 34
	                slv_reg34(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000100011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 35
	                slv_reg35(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000100100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 36
	                slv_reg36(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000100101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 37
	                slv_reg37(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000100110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 38
	                slv_reg38(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000100111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 39
	                slv_reg39(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000101000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 40
	                slv_reg40(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000101001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 41
	                slv_reg41(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000101010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 42
	                slv_reg42(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000101011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 43
	                slv_reg43(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000101100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 44
	                slv_reg44(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000101101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 45
	                slv_reg45(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000101110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 46
	                slv_reg46(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000101111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 47
	                slv_reg47(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000110000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 48
	                slv_reg48(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000110001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 49
	                slv_reg49(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000110010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 50
	                slv_reg50(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000110011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 51
	                slv_reg51(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000110100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 52
	                slv_reg52(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000110101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 53
	                slv_reg53(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000110110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 54
	                slv_reg54(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000110111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 55
	                slv_reg55(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000111000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 56
	                slv_reg56(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000111001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 57
	                slv_reg57(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000111010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 58
	                slv_reg58(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000111011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 59
	                slv_reg59(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000111100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 60
	                slv_reg60(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000111101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 61
	                slv_reg61(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000111110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 62
	                slv_reg62(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"000111111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 63
	                slv_reg63(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001000000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 64
	                slv_reg64(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001000001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 65
	                slv_reg65(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001000010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 66
	                slv_reg66(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001000011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 67
	                slv_reg67(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001000100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 68
	                slv_reg68(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001000101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 69
	                slv_reg69(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001000110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 70
	                slv_reg70(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001000111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 71
	                slv_reg71(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001001000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 72
	                slv_reg72(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001001001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 73
	                slv_reg73(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001001010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 74
	                slv_reg74(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001001011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 75
	                slv_reg75(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001001100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 76
	                slv_reg76(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001001101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 77
	                slv_reg77(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001001110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 78
	                slv_reg78(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001001111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 79
	                slv_reg79(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001010000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 80
	                slv_reg80(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001010001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 81
	                slv_reg81(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001010010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 82
	                slv_reg82(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001010011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 83
	                slv_reg83(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001010100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 84
	                slv_reg84(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001010101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 85
	                slv_reg85(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001010110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 86
	                slv_reg86(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001010111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 87
	                slv_reg87(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001011000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 88
	                slv_reg88(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001011001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 89
	                slv_reg89(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001011010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 90
	                slv_reg90(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001011011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 91
	                slv_reg91(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001011100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 92
	                slv_reg92(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001011101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 93
	                slv_reg93(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001011110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 94
	                slv_reg94(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001011111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 95
	                slv_reg95(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001100000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 96
	                slv_reg96(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001100001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 97
	                slv_reg97(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001100010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 98
	                slv_reg98(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001100011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 99
	                slv_reg99(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001100100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 100
	                slv_reg100(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001100101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 101
	                slv_reg101(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001100110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 102
	                slv_reg102(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001100111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 103
	                slv_reg103(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001101000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 104
	                slv_reg104(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001101001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 105
	                slv_reg105(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001101010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 106
	                slv_reg106(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001101011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 107
	                slv_reg107(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001101100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 108
	                slv_reg108(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001101101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 109
	                slv_reg109(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001101110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 110
	                slv_reg110(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001101111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 111
	                slv_reg111(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001110000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 112
	                slv_reg112(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001110001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 113
	                slv_reg113(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001110010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 114
	                slv_reg114(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001110011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 115
	                slv_reg115(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001110100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 116
	                slv_reg116(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001110101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 117
	                slv_reg117(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001110110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 118
	                slv_reg118(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001110111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 119
	                slv_reg119(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001111000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 120
	                slv_reg120(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001111001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 121
	                slv_reg121(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001111010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 122
	                slv_reg122(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001111011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 123
	                slv_reg123(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001111100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 124
	                slv_reg124(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001111101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 125
	                slv_reg125(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001111110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 126
	                slv_reg126(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"001111111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 127
	                slv_reg127(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010000000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 128
	                slv_reg128(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010000001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 129
	                slv_reg129(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010000010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 130
	                slv_reg130(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010000011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 131
	                slv_reg131(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010000100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 132
	                slv_reg132(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010000101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 133
	                slv_reg133(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010000110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 134
	                slv_reg134(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010000111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 135
	                slv_reg135(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010001000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 136
	                slv_reg136(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010001001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 137
	                slv_reg137(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010001010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 138
	                slv_reg138(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010001011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 139
	                slv_reg139(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010001100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 140
	                slv_reg140(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010001101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 141
	                slv_reg141(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010001110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 142
	                slv_reg142(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010001111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 143
	                slv_reg143(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010010000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 144
	                slv_reg144(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010010001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 145
	                slv_reg145(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010010010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 146
	                slv_reg146(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010010011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 147
	                slv_reg147(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010010100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 148
	                slv_reg148(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010010101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 149
	                slv_reg149(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010010110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 150
	                slv_reg150(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010010111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 151
	                slv_reg151(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010011000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 152
	                slv_reg152(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010011001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 153
	                slv_reg153(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010011010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 154
	                slv_reg154(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010011011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 155
	                slv_reg155(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010011100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 156
	                slv_reg156(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010011101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 157
	                slv_reg157(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010011110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 158
	                slv_reg158(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010011111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 159
	                slv_reg159(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010100000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 160
	                slv_reg160(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010100001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 161
	                slv_reg161(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010100010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 162
	                slv_reg162(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010100011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 163
	                slv_reg163(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010100100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 164
	                slv_reg164(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010100101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 165
	                slv_reg165(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010100110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 166
	                slv_reg166(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010100111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 167
	                slv_reg167(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010101000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 168
	                slv_reg168(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010101001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 169
	                slv_reg169(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010101010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 170
	                slv_reg170(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010101011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 171
	                slv_reg171(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010101100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 172
	                slv_reg172(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010101101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 173
	                slv_reg173(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010101110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 174
	                slv_reg174(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010101111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 175
	                slv_reg175(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010110000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 176
	                slv_reg176(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010110001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 177
	                slv_reg177(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010110010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 178
	                slv_reg178(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010110011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 179
	                slv_reg179(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010110100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 180
	                slv_reg180(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010110101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 181
	                slv_reg181(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010110110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 182
	                slv_reg182(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010110111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 183
	                slv_reg183(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010111000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 184
	                slv_reg184(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010111001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 185
	                slv_reg185(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010111010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 186
	                slv_reg186(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010111011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 187
	                slv_reg187(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010111100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 188
	                slv_reg188(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010111101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 189
	                slv_reg189(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010111110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 190
	                slv_reg190(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"010111111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 191
	                slv_reg191(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011000000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 192
	                slv_reg192(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011000001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 193
	                slv_reg193(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011000010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 194
	                slv_reg194(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011000011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 195
	                slv_reg195(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011000100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 196
	                slv_reg196(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011000101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 197
	                slv_reg197(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011000110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 198
	                slv_reg198(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011000111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 199
	                slv_reg199(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011001000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 200
	                slv_reg200(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011001001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 201
	                slv_reg201(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011001010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 202
	                slv_reg202(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011001011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 203
	                slv_reg203(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011001100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 204
	                slv_reg204(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011001101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 205
	                slv_reg205(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011001110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 206
	                slv_reg206(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011001111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 207
	                slv_reg207(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011010000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 208
	                slv_reg208(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011010001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 209
	                slv_reg209(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011010010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 210
	                slv_reg210(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011010011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 211
	                slv_reg211(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011010100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 212
	                slv_reg212(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011010101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 213
	                slv_reg213(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011010110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 214
	                slv_reg214(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011010111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 215
	                slv_reg215(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011011000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 216
	                slv_reg216(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011011001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 217
	                slv_reg217(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011011010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 218
	                slv_reg218(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011011011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 219
	                slv_reg219(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011011100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 220
	                slv_reg220(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011011101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 221
	                slv_reg221(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011011110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 222
	                slv_reg222(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011011111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 223
	                slv_reg223(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011100000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 224
	                slv_reg224(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011100001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 225
	                slv_reg225(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011100010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 226
	                slv_reg226(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011100011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 227
	                slv_reg227(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011100100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 228
	                slv_reg228(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011100101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 229
	                slv_reg229(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011100110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 230
	                slv_reg230(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011100111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 231
	                slv_reg231(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011101000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 232
	                slv_reg232(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011101001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 233
	                slv_reg233(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011101010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 234
	                slv_reg234(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011101011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 235
	                slv_reg235(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011101100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 236
	                slv_reg236(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011101101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 237
	                slv_reg237(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011101110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 238
	                slv_reg238(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011101111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 239
	                slv_reg239(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011110000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 240
	                slv_reg240(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011110001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 241
	                slv_reg241(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011110010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 242
	                slv_reg242(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011110011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 243
	                slv_reg243(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011110100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 244
	                slv_reg244(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011110101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 245
	                slv_reg245(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011110110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 246
	                slv_reg246(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011110111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 247
	                slv_reg247(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011111000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 248
	                slv_reg248(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011111001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 249
	                slv_reg249(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011111010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 250
	                slv_reg250(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011111011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 251
	                slv_reg251(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011111100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 252
	                slv_reg252(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011111101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 253
	                slv_reg253(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011111110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 254
	                slv_reg254(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"011111111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 255
	                slv_reg255(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100000000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 256
	                slv_reg256(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100000001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 257
	                slv_reg257(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100000010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 258
	                slv_reg258(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100000011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 259
	                slv_reg259(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100000100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 260
	                slv_reg260(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100000101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 261
	                slv_reg261(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100000110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 262
	                slv_reg262(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100000111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 263
	                slv_reg263(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100001000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 264
	                slv_reg264(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100001001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 265
	                slv_reg265(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100001010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 266
	                slv_reg266(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100001011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 267
	                slv_reg267(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100001100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 268
	                slv_reg268(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100001101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 269
	                slv_reg269(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100001110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 270
	                slv_reg270(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100001111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 271
	                slv_reg271(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100010000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 272
	                slv_reg272(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100010001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 273
	                slv_reg273(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100010010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 274
	                slv_reg274(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100010011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 275
	                slv_reg275(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100010100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 276
	                slv_reg276(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100010101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 277
	                slv_reg277(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100010110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 278
	                slv_reg278(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100010111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 279
	                slv_reg279(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100011000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 280
	                slv_reg280(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100011001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 281
	                slv_reg281(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100011010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 282
	                slv_reg282(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100011011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 283
	                slv_reg283(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100011100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 284
	                slv_reg284(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100011101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 285
	                slv_reg285(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100011110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 286
	                slv_reg286(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100011111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 287
	                slv_reg287(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100100000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 288
	                slv_reg288(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100100001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 289
	                slv_reg289(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100100010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 290
	                slv_reg290(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100100011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 291
	                slv_reg291(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100100100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 292
	                slv_reg292(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100100101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 293
	                slv_reg293(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100100110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 294
	                slv_reg294(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100100111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 295
	                slv_reg295(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100101000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 296
	                slv_reg296(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100101001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 297
	                slv_reg297(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100101010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 298
	                slv_reg298(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100101011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 299
	                slv_reg299(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100101100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 300
	                slv_reg300(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100101101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 301
	                slv_reg301(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100101110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 302
	                slv_reg302(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100101111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 303
	                slv_reg303(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100110000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 304
	                slv_reg304(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100110001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 305
	                slv_reg305(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100110010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 306
	                slv_reg306(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100110011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 307
	                slv_reg307(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100110100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 308
	                slv_reg308(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100110101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 309
	                slv_reg309(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100110110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 310
	                slv_reg310(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100110111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 311
	                slv_reg311(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100111000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 312
	                slv_reg312(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100111001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 313
	                slv_reg313(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100111010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 314
	                slv_reg314(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100111011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 315
	                slv_reg315(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100111100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 316
	                slv_reg316(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100111101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 317
	                slv_reg317(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100111110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 318
	                slv_reg318(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"100111111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 319
	                slv_reg319(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101000000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 320
	                slv_reg320(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101000001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 321
	                slv_reg321(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101000010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 322
	                slv_reg322(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101000011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 323
	                slv_reg323(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101000100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 324
	                slv_reg324(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101000101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 325
	                slv_reg325(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101000110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 326
	                slv_reg326(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101000111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 327
	                slv_reg327(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101001000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 328
	                slv_reg328(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101001001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 329
	                slv_reg329(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101001010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 330
	                slv_reg330(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101001011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 331
	                slv_reg331(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101001100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 332
	                slv_reg332(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101001101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 333
	                slv_reg333(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101001110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 334
	                slv_reg334(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101001111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 335
	                slv_reg335(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101010000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 336
	                slv_reg336(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101010001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 337
	                slv_reg337(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101010010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 338
	                slv_reg338(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101010011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 339
	                slv_reg339(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101010100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 340
	                slv_reg340(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101010101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 341
	                slv_reg341(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101010110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 342
	                slv_reg342(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101010111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 343
	                slv_reg343(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101011000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 344
	                slv_reg344(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101011001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 345
	                slv_reg345(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101011010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 346
	                slv_reg346(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101011011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 347
	                slv_reg347(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101011100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 348
	                slv_reg348(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101011101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 349
	                slv_reg349(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101011110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 350
	                slv_reg350(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101011111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 351
	                slv_reg351(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101100000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 352
	                slv_reg352(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101100001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 353
	                slv_reg353(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101100010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 354
	                slv_reg354(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101100011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 355
	                slv_reg355(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101100100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 356
	                slv_reg356(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101100101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 357
	                slv_reg357(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101100110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 358
	                slv_reg358(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101100111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 359
	                slv_reg359(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101101000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 360
	                slv_reg360(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101101001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 361
	                slv_reg361(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101101010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 362
	                slv_reg362(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101101011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 363
	                slv_reg363(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101101100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 364
	                slv_reg364(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101101101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 365
	                slv_reg365(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101101110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 366
	                slv_reg366(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101101111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 367
	                slv_reg367(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101110000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 368
	                slv_reg368(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101110001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 369
	                slv_reg369(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101110010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 370
	                slv_reg370(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101110011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 371
	                slv_reg371(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101110100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 372
	                slv_reg372(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101110101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 373
	                slv_reg373(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101110110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 374
	                slv_reg374(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101110111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 375
	                slv_reg375(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101111000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 376
	                slv_reg376(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101111001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 377
	                slv_reg377(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101111010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 378
	                slv_reg378(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101111011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 379
	                slv_reg379(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101111100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 380
	                slv_reg380(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101111101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 381
	                slv_reg381(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101111110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 382
	                slv_reg382(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"101111111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 383
	                slv_reg383(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110000000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 384
	                slv_reg384(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110000001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 385
	                slv_reg385(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110000010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 386
	                slv_reg386(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110000011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 387
	                slv_reg387(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110000100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 388
	                slv_reg388(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110000101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 389
	                slv_reg389(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110000110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 390
	                slv_reg390(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110000111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 391
	                slv_reg391(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110001000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 392
	                slv_reg392(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110001001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 393
	                slv_reg393(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110001010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 394
	                slv_reg394(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110001011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 395
	                slv_reg395(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110001100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 396
	                slv_reg396(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110001101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 397
	                slv_reg397(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110001110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 398
	                slv_reg398(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110001111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 399
	                slv_reg399(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110010000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 400
	                slv_reg400(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110010001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 401
	                slv_reg401(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110010010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 402
	                slv_reg402(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110010011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 403
	                slv_reg403(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110010100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 404
	                slv_reg404(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110010101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 405
	                slv_reg405(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110010110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 406
	                slv_reg406(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110010111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 407
	                slv_reg407(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110011000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 408
	                slv_reg408(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110011001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 409
	                slv_reg409(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110011010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 410
	                slv_reg410(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110011011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 411
	                slv_reg411(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110011100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 412
	                slv_reg412(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110011101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 413
	                slv_reg413(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110011110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 414
	                slv_reg414(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110011111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 415
	                slv_reg415(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110100000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 416
	                slv_reg416(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110100001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 417
	                slv_reg417(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110100010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 418
	                slv_reg418(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110100011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 419
	                slv_reg419(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110100100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 420
	                slv_reg420(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110100101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 421
	                slv_reg421(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110100110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 422
	                slv_reg422(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110100111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 423
	                slv_reg423(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110101000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 424
	                slv_reg424(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110101001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 425
	                slv_reg425(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110101010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 426
	                slv_reg426(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110101011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 427
	                slv_reg427(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110101100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 428
	                slv_reg428(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110101101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 429
	                slv_reg429(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110101110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 430
	                slv_reg430(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110101111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 431
	                slv_reg431(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110110000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 432
	                slv_reg432(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110110001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 433
	                slv_reg433(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110110010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 434
	                slv_reg434(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110110011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 435
	                slv_reg435(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110110100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 436
	                slv_reg436(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110110101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 437
	                slv_reg437(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110110110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 438
	                slv_reg438(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110110111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 439
	                slv_reg439(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110111000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 440
	                slv_reg440(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110111001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 441
	                slv_reg441(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110111010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 442
	                slv_reg442(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110111011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 443
	                slv_reg443(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110111100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 444
	                slv_reg444(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110111101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 445
	                slv_reg445(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110111110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 446
	                slv_reg446(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"110111111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 447
	                slv_reg447(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111000000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 448
	                slv_reg448(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111000001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 449
	                slv_reg449(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111000010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 450
	                slv_reg450(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111000011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 451
	                slv_reg451(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111000100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 452
	                slv_reg452(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111000101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 453
	                slv_reg453(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111000110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 454
	                slv_reg454(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111000111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 455
	                slv_reg455(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111001000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 456
	                slv_reg456(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111001001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 457
	                slv_reg457(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111001010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 458
	                slv_reg458(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111001011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 459
	                slv_reg459(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111001100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 460
	                slv_reg460(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111001101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 461
	                slv_reg461(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111001110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 462
	                slv_reg462(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111001111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 463
	                slv_reg463(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111010000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 464
	                slv_reg464(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111010001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 465
	                slv_reg465(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111010010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 466
	                slv_reg466(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111010011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 467
	                slv_reg467(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111010100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 468
	                slv_reg468(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111010101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 469
	                slv_reg469(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111010110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 470
	                slv_reg470(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111010111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 471
	                slv_reg471(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111011000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 472
	                slv_reg472(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111011001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 473
	                slv_reg473(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111011010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 474
	                slv_reg474(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111011011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 475
	                slv_reg475(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111011100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 476
	                slv_reg476(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111011101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 477
	                slv_reg477(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111011110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 478
	                slv_reg478(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111011111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 479
	                slv_reg479(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111100000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 480
	                slv_reg480(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111100001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 481
	                slv_reg481(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111100010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 482
	                slv_reg482(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111100011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 483
	                slv_reg483(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111100100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 484
	                slv_reg484(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111100101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 485
	                slv_reg485(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111100110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 486
	                slv_reg486(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111100111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 487
	                slv_reg487(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111101000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 488
	                slv_reg488(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111101001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 489
	                slv_reg489(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111101010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 490
	                slv_reg490(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111101011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 491
	                slv_reg491(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111101100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 492
	                slv_reg492(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111101101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 493
	                slv_reg493(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111101110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 494
	                slv_reg494(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111101111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 495
	                slv_reg495(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111110000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 496
	                slv_reg496(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111110001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 497
	                slv_reg497(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111110010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 498
	                slv_reg498(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111110011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 499
	                slv_reg499(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111110100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 500
	                slv_reg500(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111110101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 501
	                slv_reg501(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111110110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 502
	                slv_reg502(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111110111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 503
	                slv_reg503(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111111000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 504
	                slv_reg504(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111111001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 505
	                slv_reg505(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111111010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 506
	                slv_reg506(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111111011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 507
	                slv_reg507(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111111100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 508
	                slv_reg508(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111111101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 509
	                slv_reg509(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111111110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 510
	                slv_reg510(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"111111111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( S_AXI_WSTRB(byte_index) = '1' ) then
	                -- Respective byte enables are asserted as per write strobes                   
	                -- slave registor 511
	                slv_reg511(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when others =>
	            slv_reg0 <= slv_reg0;
	            slv_reg1 <= slv_reg1;
	            slv_reg2 <= slv_reg2;
	            slv_reg3 <= slv_reg3;
	            slv_reg4 <= slv_reg4;
	            slv_reg5 <= slv_reg5;
	            slv_reg6 <= slv_reg6;
	            slv_reg7 <= slv_reg7;
	            slv_reg8 <= slv_reg8;
	            slv_reg9 <= slv_reg9;
	            slv_reg10 <= slv_reg10;
	            slv_reg11 <= slv_reg11;
	            slv_reg12 <= slv_reg12;
	            slv_reg13 <= slv_reg13;
	            slv_reg14 <= slv_reg14;
	            slv_reg15 <= slv_reg15;
	            slv_reg16 <= slv_reg16;
	            slv_reg17 <= slv_reg17;
	            slv_reg18 <= slv_reg18;
	            slv_reg19 <= slv_reg19;
	            slv_reg20 <= slv_reg20;
	            slv_reg21 <= slv_reg21;
	            slv_reg22 <= slv_reg22;
	            slv_reg23 <= slv_reg23;
	            slv_reg24 <= slv_reg24;
	            slv_reg25 <= slv_reg25;
	            slv_reg26 <= slv_reg26;
	            slv_reg27 <= slv_reg27;
	            slv_reg28 <= slv_reg28;
	            slv_reg29 <= slv_reg29;
	            slv_reg30 <= slv_reg30;
	            slv_reg31 <= slv_reg31;
	            slv_reg32 <= slv_reg32;
	            slv_reg33 <= slv_reg33;
	            slv_reg34 <= slv_reg34;
	            slv_reg35 <= slv_reg35;
	            slv_reg36 <= slv_reg36;
	            slv_reg37 <= slv_reg37;
	            slv_reg38 <= slv_reg38;
	            slv_reg39 <= slv_reg39;
	            slv_reg40 <= slv_reg40;
	            slv_reg41 <= slv_reg41;
	            slv_reg42 <= slv_reg42;
	            slv_reg43 <= slv_reg43;
	            slv_reg44 <= slv_reg44;
	            slv_reg45 <= slv_reg45;
	            slv_reg46 <= slv_reg46;
	            slv_reg47 <= slv_reg47;
	            slv_reg48 <= slv_reg48;
	            slv_reg49 <= slv_reg49;
	            slv_reg50 <= slv_reg50;
	            slv_reg51 <= slv_reg51;
	            slv_reg52 <= slv_reg52;
	            slv_reg53 <= slv_reg53;
	            slv_reg54 <= slv_reg54;
	            slv_reg55 <= slv_reg55;
	            slv_reg56 <= slv_reg56;
	            slv_reg57 <= slv_reg57;
	            slv_reg58 <= slv_reg58;
	            slv_reg59 <= slv_reg59;
	            slv_reg60 <= slv_reg60;
	            slv_reg61 <= slv_reg61;
	            slv_reg62 <= slv_reg62;
	            slv_reg63 <= slv_reg63;
	            slv_reg64 <= slv_reg64;
	            slv_reg65 <= slv_reg65;
	            slv_reg66 <= slv_reg66;
	            slv_reg67 <= slv_reg67;
	            slv_reg68 <= slv_reg68;
	            slv_reg69 <= slv_reg69;
	            slv_reg70 <= slv_reg70;
	            slv_reg71 <= slv_reg71;
	            slv_reg72 <= slv_reg72;
	            slv_reg73 <= slv_reg73;
	            slv_reg74 <= slv_reg74;
	            slv_reg75 <= slv_reg75;
	            slv_reg76 <= slv_reg76;
	            slv_reg77 <= slv_reg77;
	            slv_reg78 <= slv_reg78;
	            slv_reg79 <= slv_reg79;
	            slv_reg80 <= slv_reg80;
	            slv_reg81 <= slv_reg81;
	            slv_reg82 <= slv_reg82;
	            slv_reg83 <= slv_reg83;
	            slv_reg84 <= slv_reg84;
	            slv_reg85 <= slv_reg85;
	            slv_reg86 <= slv_reg86;
	            slv_reg87 <= slv_reg87;
	            slv_reg88 <= slv_reg88;
	            slv_reg89 <= slv_reg89;
	            slv_reg90 <= slv_reg90;
	            slv_reg91 <= slv_reg91;
	            slv_reg92 <= slv_reg92;
	            slv_reg93 <= slv_reg93;
	            slv_reg94 <= slv_reg94;
	            slv_reg95 <= slv_reg95;
	            slv_reg96 <= slv_reg96;
	            slv_reg97 <= slv_reg97;
	            slv_reg98 <= slv_reg98;
	            slv_reg99 <= slv_reg99;
	            slv_reg100 <= slv_reg100;
	            slv_reg101 <= slv_reg101;
	            slv_reg102 <= slv_reg102;
	            slv_reg103 <= slv_reg103;
	            slv_reg104 <= slv_reg104;
	            slv_reg105 <= slv_reg105;
	            slv_reg106 <= slv_reg106;
	            slv_reg107 <= slv_reg107;
	            slv_reg108 <= slv_reg108;
	            slv_reg109 <= slv_reg109;
	            slv_reg110 <= slv_reg110;
	            slv_reg111 <= slv_reg111;
	            slv_reg112 <= slv_reg112;
	            slv_reg113 <= slv_reg113;
	            slv_reg114 <= slv_reg114;
	            slv_reg115 <= slv_reg115;
	            slv_reg116 <= slv_reg116;
	            slv_reg117 <= slv_reg117;
	            slv_reg118 <= slv_reg118;
	            slv_reg119 <= slv_reg119;
	            slv_reg120 <= slv_reg120;
	            slv_reg121 <= slv_reg121;
	            slv_reg122 <= slv_reg122;
	            slv_reg123 <= slv_reg123;
	            slv_reg124 <= slv_reg124;
	            slv_reg125 <= slv_reg125;
	            slv_reg126 <= slv_reg126;
	            slv_reg127 <= slv_reg127;
	            slv_reg128 <= slv_reg128;
	            slv_reg129 <= slv_reg129;
	            slv_reg130 <= slv_reg130;
	            slv_reg131 <= slv_reg131;
	            slv_reg132 <= slv_reg132;
	            slv_reg133 <= slv_reg133;
	            slv_reg134 <= slv_reg134;
	            slv_reg135 <= slv_reg135;
	            slv_reg136 <= slv_reg136;
	            slv_reg137 <= slv_reg137;
	            slv_reg138 <= slv_reg138;
	            slv_reg139 <= slv_reg139;
	            slv_reg140 <= slv_reg140;
	            slv_reg141 <= slv_reg141;
	            slv_reg142 <= slv_reg142;
	            slv_reg143 <= slv_reg143;
	            slv_reg144 <= slv_reg144;
	            slv_reg145 <= slv_reg145;
	            slv_reg146 <= slv_reg146;
	            slv_reg147 <= slv_reg147;
	            slv_reg148 <= slv_reg148;
	            slv_reg149 <= slv_reg149;
	            slv_reg150 <= slv_reg150;
	            slv_reg151 <= slv_reg151;
	            slv_reg152 <= slv_reg152;
	            slv_reg153 <= slv_reg153;
	            slv_reg154 <= slv_reg154;
	            slv_reg155 <= slv_reg155;
	            slv_reg156 <= slv_reg156;
	            slv_reg157 <= slv_reg157;
	            slv_reg158 <= slv_reg158;
	            slv_reg159 <= slv_reg159;
	            slv_reg160 <= slv_reg160;
	            slv_reg161 <= slv_reg161;
	            slv_reg162 <= slv_reg162;
	            slv_reg163 <= slv_reg163;
	            slv_reg164 <= slv_reg164;
	            slv_reg165 <= slv_reg165;
	            slv_reg166 <= slv_reg166;
	            slv_reg167 <= slv_reg167;
	            slv_reg168 <= slv_reg168;
	            slv_reg169 <= slv_reg169;
	            slv_reg170 <= slv_reg170;
	            slv_reg171 <= slv_reg171;
	            slv_reg172 <= slv_reg172;
	            slv_reg173 <= slv_reg173;
	            slv_reg174 <= slv_reg174;
	            slv_reg175 <= slv_reg175;
	            slv_reg176 <= slv_reg176;
	            slv_reg177 <= slv_reg177;
	            slv_reg178 <= slv_reg178;
	            slv_reg179 <= slv_reg179;
	            slv_reg180 <= slv_reg180;
	            slv_reg181 <= slv_reg181;
	            slv_reg182 <= slv_reg182;
	            slv_reg183 <= slv_reg183;
	            slv_reg184 <= slv_reg184;
	            slv_reg185 <= slv_reg185;
	            slv_reg186 <= slv_reg186;
	            slv_reg187 <= slv_reg187;
	            slv_reg188 <= slv_reg188;
	            slv_reg189 <= slv_reg189;
	            slv_reg190 <= slv_reg190;
	            slv_reg191 <= slv_reg191;
	            slv_reg192 <= slv_reg192;
	            slv_reg193 <= slv_reg193;
	            slv_reg194 <= slv_reg194;
	            slv_reg195 <= slv_reg195;
	            slv_reg196 <= slv_reg196;
	            slv_reg197 <= slv_reg197;
	            slv_reg198 <= slv_reg198;
	            slv_reg199 <= slv_reg199;
	            slv_reg200 <= slv_reg200;
	            slv_reg201 <= slv_reg201;
	            slv_reg202 <= slv_reg202;
	            slv_reg203 <= slv_reg203;
	            slv_reg204 <= slv_reg204;
	            slv_reg205 <= slv_reg205;
	            slv_reg206 <= slv_reg206;
	            slv_reg207 <= slv_reg207;
	            slv_reg208 <= slv_reg208;
	            slv_reg209 <= slv_reg209;
	            slv_reg210 <= slv_reg210;
	            slv_reg211 <= slv_reg211;
	            slv_reg212 <= slv_reg212;
	            slv_reg213 <= slv_reg213;
	            slv_reg214 <= slv_reg214;
	            slv_reg215 <= slv_reg215;
	            slv_reg216 <= slv_reg216;
	            slv_reg217 <= slv_reg217;
	            slv_reg218 <= slv_reg218;
	            slv_reg219 <= slv_reg219;
	            slv_reg220 <= slv_reg220;
	            slv_reg221 <= slv_reg221;
	            slv_reg222 <= slv_reg222;
	            slv_reg223 <= slv_reg223;
	            slv_reg224 <= slv_reg224;
	            slv_reg225 <= slv_reg225;
	            slv_reg226 <= slv_reg226;
	            slv_reg227 <= slv_reg227;
	            slv_reg228 <= slv_reg228;
	            slv_reg229 <= slv_reg229;
	            slv_reg230 <= slv_reg230;
	            slv_reg231 <= slv_reg231;
	            slv_reg232 <= slv_reg232;
	            slv_reg233 <= slv_reg233;
	            slv_reg234 <= slv_reg234;
	            slv_reg235 <= slv_reg235;
	            slv_reg236 <= slv_reg236;
	            slv_reg237 <= slv_reg237;
	            slv_reg238 <= slv_reg238;
	            slv_reg239 <= slv_reg239;
	            slv_reg240 <= slv_reg240;
	            slv_reg241 <= slv_reg241;
	            slv_reg242 <= slv_reg242;
	            slv_reg243 <= slv_reg243;
	            slv_reg244 <= slv_reg244;
	            slv_reg245 <= slv_reg245;
	            slv_reg246 <= slv_reg246;
	            slv_reg247 <= slv_reg247;
	            slv_reg248 <= slv_reg248;
	            slv_reg249 <= slv_reg249;
	            slv_reg250 <= slv_reg250;
	            slv_reg251 <= slv_reg251;
	            slv_reg252 <= slv_reg252;
	            slv_reg253 <= slv_reg253;
	            slv_reg254 <= slv_reg254;
	            slv_reg255 <= slv_reg255;
	            slv_reg256 <= slv_reg256;
	            slv_reg257 <= slv_reg257;
	            slv_reg258 <= slv_reg258;
	            slv_reg259 <= slv_reg259;
	            slv_reg260 <= slv_reg260;
	            slv_reg261 <= slv_reg261;
	            slv_reg262 <= slv_reg262;
	            slv_reg263 <= slv_reg263;
	            slv_reg264 <= slv_reg264;
	            slv_reg265 <= slv_reg265;
	            slv_reg266 <= slv_reg266;
	            slv_reg267 <= slv_reg267;
	            slv_reg268 <= slv_reg268;
	            slv_reg269 <= slv_reg269;
	            slv_reg270 <= slv_reg270;
	            slv_reg271 <= slv_reg271;
	            slv_reg272 <= slv_reg272;
	            slv_reg273 <= slv_reg273;
	            slv_reg274 <= slv_reg274;
	            slv_reg275 <= slv_reg275;
	            slv_reg276 <= slv_reg276;
	            slv_reg277 <= slv_reg277;
	            slv_reg278 <= slv_reg278;
	            slv_reg279 <= slv_reg279;
	            slv_reg280 <= slv_reg280;
	            slv_reg281 <= slv_reg281;
	            slv_reg282 <= slv_reg282;
	            slv_reg283 <= slv_reg283;
	            slv_reg284 <= slv_reg284;
	            slv_reg285 <= slv_reg285;
	            slv_reg286 <= slv_reg286;
	            slv_reg287 <= slv_reg287;
	            slv_reg288 <= slv_reg288;
	            slv_reg289 <= slv_reg289;
	            slv_reg290 <= slv_reg290;
	            slv_reg291 <= slv_reg291;
	            slv_reg292 <= slv_reg292;
	            slv_reg293 <= slv_reg293;
	            slv_reg294 <= slv_reg294;
	            slv_reg295 <= slv_reg295;
	            slv_reg296 <= slv_reg296;
	            slv_reg297 <= slv_reg297;
	            slv_reg298 <= slv_reg298;
	            slv_reg299 <= slv_reg299;
	            slv_reg300 <= slv_reg300;
	            slv_reg301 <= slv_reg301;
	            slv_reg302 <= slv_reg302;
	            slv_reg303 <= slv_reg303;
	            slv_reg304 <= slv_reg304;
	            slv_reg305 <= slv_reg305;
	            slv_reg306 <= slv_reg306;
	            slv_reg307 <= slv_reg307;
	            slv_reg308 <= slv_reg308;
	            slv_reg309 <= slv_reg309;
	            slv_reg310 <= slv_reg310;
	            slv_reg311 <= slv_reg311;
	            slv_reg312 <= slv_reg312;
	            slv_reg313 <= slv_reg313;
	            slv_reg314 <= slv_reg314;
	            slv_reg315 <= slv_reg315;
	            slv_reg316 <= slv_reg316;
	            slv_reg317 <= slv_reg317;
	            slv_reg318 <= slv_reg318;
	            slv_reg319 <= slv_reg319;
	            slv_reg320 <= slv_reg320;
	            slv_reg321 <= slv_reg321;
	            slv_reg322 <= slv_reg322;
	            slv_reg323 <= slv_reg323;
	            slv_reg324 <= slv_reg324;
	            slv_reg325 <= slv_reg325;
	            slv_reg326 <= slv_reg326;
	            slv_reg327 <= slv_reg327;
	            slv_reg328 <= slv_reg328;
	            slv_reg329 <= slv_reg329;
	            slv_reg330 <= slv_reg330;
	            slv_reg331 <= slv_reg331;
	            slv_reg332 <= slv_reg332;
	            slv_reg333 <= slv_reg333;
	            slv_reg334 <= slv_reg334;
	            slv_reg335 <= slv_reg335;
	            slv_reg336 <= slv_reg336;
	            slv_reg337 <= slv_reg337;
	            slv_reg338 <= slv_reg338;
	            slv_reg339 <= slv_reg339;
	            slv_reg340 <= slv_reg340;
	            slv_reg341 <= slv_reg341;
	            slv_reg342 <= slv_reg342;
	            slv_reg343 <= slv_reg343;
	            slv_reg344 <= slv_reg344;
	            slv_reg345 <= slv_reg345;
	            slv_reg346 <= slv_reg346;
	            slv_reg347 <= slv_reg347;
	            slv_reg348 <= slv_reg348;
	            slv_reg349 <= slv_reg349;
	            slv_reg350 <= slv_reg350;
	            slv_reg351 <= slv_reg351;
	            slv_reg352 <= slv_reg352;
	            slv_reg353 <= slv_reg353;
	            slv_reg354 <= slv_reg354;
	            slv_reg355 <= slv_reg355;
	            slv_reg356 <= slv_reg356;
	            slv_reg357 <= slv_reg357;
	            slv_reg358 <= slv_reg358;
	            slv_reg359 <= slv_reg359;
	            slv_reg360 <= slv_reg360;
	            slv_reg361 <= slv_reg361;
	            slv_reg362 <= slv_reg362;
	            slv_reg363 <= slv_reg363;
	            slv_reg364 <= slv_reg364;
	            slv_reg365 <= slv_reg365;
	            slv_reg366 <= slv_reg366;
	            slv_reg367 <= slv_reg367;
	            slv_reg368 <= slv_reg368;
	            slv_reg369 <= slv_reg369;
	            slv_reg370 <= slv_reg370;
	            slv_reg371 <= slv_reg371;
	            slv_reg372 <= slv_reg372;
	            slv_reg373 <= slv_reg373;
	            slv_reg374 <= slv_reg374;
	            slv_reg375 <= slv_reg375;
	            slv_reg376 <= slv_reg376;
	            slv_reg377 <= slv_reg377;
	            slv_reg378 <= slv_reg378;
	            slv_reg379 <= slv_reg379;
	            slv_reg380 <= slv_reg380;
	            slv_reg381 <= slv_reg381;
	            slv_reg382 <= slv_reg382;
	            slv_reg383 <= slv_reg383;
	            slv_reg384 <= slv_reg384;
	            slv_reg385 <= slv_reg385;
	            slv_reg386 <= slv_reg386;
	            slv_reg387 <= slv_reg387;
	            slv_reg388 <= slv_reg388;
	            slv_reg389 <= slv_reg389;
	            slv_reg390 <= slv_reg390;
	            slv_reg391 <= slv_reg391;
	            slv_reg392 <= slv_reg392;
	            slv_reg393 <= slv_reg393;
	            slv_reg394 <= slv_reg394;
	            slv_reg395 <= slv_reg395;
	            slv_reg396 <= slv_reg396;
	            slv_reg397 <= slv_reg397;
	            slv_reg398 <= slv_reg398;
	            slv_reg399 <= slv_reg399;
	            slv_reg400 <= slv_reg400;
	            slv_reg401 <= slv_reg401;
	            slv_reg402 <= slv_reg402;
	            slv_reg403 <= slv_reg403;
	            slv_reg404 <= slv_reg404;
	            slv_reg405 <= slv_reg405;
	            slv_reg406 <= slv_reg406;
	            slv_reg407 <= slv_reg407;
	            slv_reg408 <= slv_reg408;
	            slv_reg409 <= slv_reg409;
	            slv_reg410 <= slv_reg410;
	            slv_reg411 <= slv_reg411;
	            slv_reg412 <= slv_reg412;
	            slv_reg413 <= slv_reg413;
	            slv_reg414 <= slv_reg414;
	            slv_reg415 <= slv_reg415;
	            slv_reg416 <= slv_reg416;
	            slv_reg417 <= slv_reg417;
	            slv_reg418 <= slv_reg418;
	            slv_reg419 <= slv_reg419;
	            slv_reg420 <= slv_reg420;
	            slv_reg421 <= slv_reg421;
	            slv_reg422 <= slv_reg422;
	            slv_reg423 <= slv_reg423;
	            slv_reg424 <= slv_reg424;
	            slv_reg425 <= slv_reg425;
	            slv_reg426 <= slv_reg426;
	            slv_reg427 <= slv_reg427;
	            slv_reg428 <= slv_reg428;
	            slv_reg429 <= slv_reg429;
	            slv_reg430 <= slv_reg430;
	            slv_reg431 <= slv_reg431;
	            slv_reg432 <= slv_reg432;
	            slv_reg433 <= slv_reg433;
	            slv_reg434 <= slv_reg434;
	            slv_reg435 <= slv_reg435;
	            slv_reg436 <= slv_reg436;
	            slv_reg437 <= slv_reg437;
	            slv_reg438 <= slv_reg438;
	            slv_reg439 <= slv_reg439;
	            slv_reg440 <= slv_reg440;
	            slv_reg441 <= slv_reg441;
	            slv_reg442 <= slv_reg442;
	            slv_reg443 <= slv_reg443;
	            slv_reg444 <= slv_reg444;
	            slv_reg445 <= slv_reg445;
	            slv_reg446 <= slv_reg446;
	            slv_reg447 <= slv_reg447;
	            slv_reg448 <= slv_reg448;
	            slv_reg449 <= slv_reg449;
	            slv_reg450 <= slv_reg450;
	            slv_reg451 <= slv_reg451;
	            slv_reg452 <= slv_reg452;
	            slv_reg453 <= slv_reg453;
	            slv_reg454 <= slv_reg454;
	            slv_reg455 <= slv_reg455;
	            slv_reg456 <= slv_reg456;
	            slv_reg457 <= slv_reg457;
	            slv_reg458 <= slv_reg458;
	            slv_reg459 <= slv_reg459;
	            slv_reg460 <= slv_reg460;
	            slv_reg461 <= slv_reg461;
	            slv_reg462 <= slv_reg462;
	            slv_reg463 <= slv_reg463;
	            slv_reg464 <= slv_reg464;
	            slv_reg465 <= slv_reg465;
	            slv_reg466 <= slv_reg466;
	            slv_reg467 <= slv_reg467;
	            slv_reg468 <= slv_reg468;
	            slv_reg469 <= slv_reg469;
	            slv_reg470 <= slv_reg470;
	            slv_reg471 <= slv_reg471;
	            slv_reg472 <= slv_reg472;
	            slv_reg473 <= slv_reg473;
	            slv_reg474 <= slv_reg474;
	            slv_reg475 <= slv_reg475;
	            slv_reg476 <= slv_reg476;
	            slv_reg477 <= slv_reg477;
	            slv_reg478 <= slv_reg478;
	            slv_reg479 <= slv_reg479;
	            slv_reg480 <= slv_reg480;
	            slv_reg481 <= slv_reg481;
	            slv_reg482 <= slv_reg482;
	            slv_reg483 <= slv_reg483;
	            slv_reg484 <= slv_reg484;
	            slv_reg485 <= slv_reg485;
	            slv_reg486 <= slv_reg486;
	            slv_reg487 <= slv_reg487;
	            slv_reg488 <= slv_reg488;
	            slv_reg489 <= slv_reg489;
	            slv_reg490 <= slv_reg490;
	            slv_reg491 <= slv_reg491;
	            slv_reg492 <= slv_reg492;
	            slv_reg493 <= slv_reg493;
	            slv_reg494 <= slv_reg494;
	            slv_reg495 <= slv_reg495;
	            slv_reg496 <= slv_reg496;
	            slv_reg497 <= slv_reg497;
	            slv_reg498 <= slv_reg498;
	            slv_reg499 <= slv_reg499;
	            slv_reg500 <= slv_reg500;
	            slv_reg501 <= slv_reg501;
	            slv_reg502 <= slv_reg502;
	            slv_reg503 <= slv_reg503;
	            slv_reg504 <= slv_reg504;
	            slv_reg505 <= slv_reg505;
	            slv_reg506 <= slv_reg506;
	            slv_reg507 <= slv_reg507;
	            slv_reg508 <= slv_reg508;
	            slv_reg509 <= slv_reg509;
	            slv_reg510 <= slv_reg510;
	            slv_reg511 <= slv_reg511;
	        end case;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement read state machine
	 process (S_AXI_ACLK)                                          
	   begin                                          
	     if rising_edge(S_AXI_ACLK) then                                           
	        if S_AXI_ARESETN = '0' then                                          
	          --asserting initial values to all 0's during reset                                          
	          axi_arready <= '0';                                          
	          axi_rvalid <= '0';                                          
	          axi_rresp <= (others => '0');                                          
	          state_read <= Idle;                                          
	        else                                          
	          case (state_read) is                                          
	            when Idle =>		--Initial state inidicating reset is done and ready to receive read/write transactions                                          
	                if (S_AXI_ARESETN = '1') then                                          
	                  axi_arready <= '1';                                          
	                  state_read <= Raddr;                                          
	                else state_read <= state_read;                                          
	                end if;                                          
	            when Raddr =>		--At this state, slave is ready to receive address along with corresponding control signals                                          
	                if (S_AXI_ARVALID = '1' and axi_arready = '1') then                                          
	                  state_read <= Rdata;                                          
	                  axi_rvalid <= '1';                                          
	                  axi_arready <= '0';                                          
	                  axi_araddr <= S_AXI_ARADDR;                                          
	                else                                          
	                  state_read <= state_read;                                          
	                end if;                                          
	            when Rdata =>		--At this state, slave is ready to send the data packets until the number of transfers is equal to burst length                                          
	                if (axi_rvalid = '1' and S_AXI_RREADY = '1') then                                          
	                  axi_rvalid <= '0';                                          
	                  axi_arready <= '1';                                          
	                  state_read <= Raddr;                                          
	                else                                          
	                  state_read <= state_read;                                          
	                end if;                                          
	            when others =>      --reserved                                          
	                axi_arready <= '0';                                          
	                axi_rvalid <= '0';                                          
	           end case;                                          
	         end if;                                          
	       end if;                                                   
	  end process;                                          
	-- Implement memory mapped register select and read logic generation
	 S_AXI_RDATA <= slv_reg0 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000000000" ) else 
	 slv_reg1 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000000001" ) else 
	 slv_reg2 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000000010" ) else 
	 slv_reg3 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000000011" ) else 
	 slv_reg4 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000000100" ) else 
	 slv_reg5 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000000101" ) else 
	 slv_reg6 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000000110" ) else 
	 slv_reg7 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000000111" ) else 
	 slv_reg8 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000001000" ) else 
	 slv_reg9 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000001001" ) else 
	 slv_reg10 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000001010" ) else 
	 slv_reg11 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000001011" ) else 
	 slv_reg12 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000001100" ) else 
	 slv_reg13 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000001101" ) else 
	 slv_reg14 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000001110" ) else 
	 slv_reg15 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000001111" ) else 
	 slv_reg16 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000010000" ) else 
	 slv_reg17 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000010001" ) else 
	 slv_reg18 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000010010" ) else 
	 slv_reg19 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000010011" ) else 
	 slv_reg20 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000010100" ) else 
	 slv_reg21 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000010101" ) else 
	 slv_reg22 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000010110" ) else 
	 slv_reg23 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000010111" ) else 
	 slv_reg24 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000011000" ) else 
	 slv_reg25 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000011001" ) else 
	 slv_reg26 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000011010" ) else 
	 slv_reg27 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000011011" ) else 
	 slv_reg28 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000011100" ) else 
	 slv_reg29 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000011101" ) else 
	 slv_reg30 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000011110" ) else 
	 slv_reg31 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000011111" ) else 
	 slv_reg32 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000100000" ) else 
	 slv_reg33 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000100001" ) else 
	 slv_reg34 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000100010" ) else 
	 slv_reg35 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000100011" ) else 
	 slv_reg36 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000100100" ) else 
	 slv_reg37 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000100101" ) else 
	 slv_reg38 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000100110" ) else 
	 slv_reg39 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000100111" ) else 
	 slv_reg40 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000101000" ) else 
	 slv_reg41 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000101001" ) else 
	 slv_reg42 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000101010" ) else 
	 slv_reg43 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000101011" ) else 
	 slv_reg44 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000101100" ) else 
	 slv_reg45 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000101101" ) else 
	 slv_reg46 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000101110" ) else 
	 slv_reg47 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000101111" ) else 
	 slv_reg48 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000110000" ) else 
	 slv_reg49 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000110001" ) else 
	 slv_reg50 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000110010" ) else 
	 slv_reg51 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000110011" ) else 
	 slv_reg52 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000110100" ) else 
	 slv_reg53 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000110101" ) else 
	 slv_reg54 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000110110" ) else 
	 slv_reg55 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000110111" ) else 
	 slv_reg56 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000111000" ) else 
	 slv_reg57 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000111001" ) else 
	 slv_reg58 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000111010" ) else 
	 slv_reg59 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000111011" ) else 
	 slv_reg60 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000111100" ) else 
	 slv_reg61 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000111101" ) else 
	 slv_reg62 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000111110" ) else 
	 slv_reg63 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "000111111" ) else 
	 slv_reg64 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001000000" ) else 
	 slv_reg65 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001000001" ) else 
	 slv_reg66 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001000010" ) else 
	 slv_reg67 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001000011" ) else 
	 slv_reg68 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001000100" ) else 
	 slv_reg69 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001000101" ) else 
	 slv_reg70 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001000110" ) else 
	 slv_reg71 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001000111" ) else 
	 slv_reg72 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001001000" ) else 
	 slv_reg73 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001001001" ) else 
	 slv_reg74 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001001010" ) else 
	 slv_reg75 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001001011" ) else 
	 slv_reg76 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001001100" ) else 
	 slv_reg77 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001001101" ) else 
	 slv_reg78 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001001110" ) else 
	 slv_reg79 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001001111" ) else 
	 slv_reg80 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001010000" ) else 
	 slv_reg81 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001010001" ) else 
	 slv_reg82 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001010010" ) else 
	 slv_reg83 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001010011" ) else 
	 slv_reg84 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001010100" ) else 
	 slv_reg85 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001010101" ) else 
	 slv_reg86 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001010110" ) else 
	 slv_reg87 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001010111" ) else 
	 slv_reg88 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001011000" ) else 
	 slv_reg89 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001011001" ) else 
	 slv_reg90 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001011010" ) else 
	 slv_reg91 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001011011" ) else 
	 slv_reg92 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001011100" ) else 
	 slv_reg93 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001011101" ) else 
	 slv_reg94 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001011110" ) else 
	 slv_reg95 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001011111" ) else 
	 slv_reg96 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001100000" ) else 
	 slv_reg97 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001100001" ) else 
	 slv_reg98 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001100010" ) else 
	 slv_reg99 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001100011" ) else 
	 slv_reg100 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001100100" ) else 
	 slv_reg101 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001100101" ) else 
	 slv_reg102 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001100110" ) else 
	 slv_reg103 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001100111" ) else 
	 slv_reg104 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001101000" ) else 
	 slv_reg105 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001101001" ) else 
	 slv_reg106 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001101010" ) else 
	 slv_reg107 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001101011" ) else 
	 slv_reg108 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001101100" ) else 
	 slv_reg109 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001101101" ) else 
	 slv_reg110 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001101110" ) else 
	 slv_reg111 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001101111" ) else 
	 slv_reg112 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001110000" ) else 
	 slv_reg113 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001110001" ) else 
	 slv_reg114 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001110010" ) else 
	 slv_reg115 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001110011" ) else 
	 slv_reg116 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001110100" ) else 
	 slv_reg117 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001110101" ) else 
	 slv_reg118 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001110110" ) else 
	 slv_reg119 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001110111" ) else 
	 slv_reg120 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001111000" ) else 
	 slv_reg121 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001111001" ) else 
	 slv_reg122 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001111010" ) else 
	 slv_reg123 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001111011" ) else 
	 slv_reg124 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001111100" ) else 
	 slv_reg125 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001111101" ) else 
	 slv_reg126 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001111110" ) else 
	 slv_reg127 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "001111111" ) else 
	 slv_reg128 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010000000" ) else 
	 slv_reg129 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010000001" ) else 
	 slv_reg130 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010000010" ) else 
	 slv_reg131 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010000011" ) else 
	 slv_reg132 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010000100" ) else 
	 slv_reg133 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010000101" ) else 
	 slv_reg134 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010000110" ) else 
	 slv_reg135 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010000111" ) else 
	 slv_reg136 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010001000" ) else 
	 slv_reg137 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010001001" ) else 
	 slv_reg138 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010001010" ) else 
	 slv_reg139 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010001011" ) else 
	 slv_reg140 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010001100" ) else 
	 slv_reg141 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010001101" ) else 
	 slv_reg142 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010001110" ) else 
	 slv_reg143 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010001111" ) else 
	 slv_reg144 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010010000" ) else 
	 slv_reg145 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010010001" ) else 
	 slv_reg146 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010010010" ) else 
	 slv_reg147 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010010011" ) else 
	 slv_reg148 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010010100" ) else 
	 slv_reg149 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010010101" ) else 
	 slv_reg150 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010010110" ) else 
	 slv_reg151 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010010111" ) else 
	 slv_reg152 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010011000" ) else 
	 slv_reg153 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010011001" ) else 
	 slv_reg154 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010011010" ) else 
	 slv_reg155 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010011011" ) else 
	 slv_reg156 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010011100" ) else 
	 slv_reg157 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010011101" ) else 
	 slv_reg158 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010011110" ) else 
	 slv_reg159 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010011111" ) else 
	 slv_reg160 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010100000" ) else 
	 slv_reg161 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010100001" ) else 
	 slv_reg162 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010100010" ) else 
	 slv_reg163 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010100011" ) else 
	 slv_reg164 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010100100" ) else 
	 slv_reg165 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010100101" ) else 
	 slv_reg166 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010100110" ) else 
	 slv_reg167 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010100111" ) else 
	 slv_reg168 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010101000" ) else 
	 slv_reg169 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010101001" ) else 
	 slv_reg170 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010101010" ) else 
	 slv_reg171 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010101011" ) else 
	 slv_reg172 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010101100" ) else 
	 slv_reg173 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010101101" ) else 
	 slv_reg174 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010101110" ) else 
	 slv_reg175 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010101111" ) else 
	 slv_reg176 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010110000" ) else 
	 slv_reg177 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010110001" ) else 
	 slv_reg178 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010110010" ) else 
	 slv_reg179 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010110011" ) else 
	 slv_reg180 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010110100" ) else 
	 slv_reg181 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010110101" ) else 
	 slv_reg182 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010110110" ) else 
	 slv_reg183 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010110111" ) else 
	 slv_reg184 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010111000" ) else 
	 slv_reg185 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010111001" ) else 
	 slv_reg186 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010111010" ) else 
	 slv_reg187 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010111011" ) else 
	 slv_reg188 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010111100" ) else 
	 slv_reg189 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010111101" ) else 
	 slv_reg190 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010111110" ) else 
	 slv_reg191 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "010111111" ) else 
	 slv_reg192 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011000000" ) else 
	 slv_reg193 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011000001" ) else 
	 slv_reg194 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011000010" ) else 
	 slv_reg195 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011000011" ) else 
	 slv_reg196 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011000100" ) else 
	 slv_reg197 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011000101" ) else 
	 slv_reg198 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011000110" ) else 
	 slv_reg199 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011000111" ) else 
	 slv_reg200 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011001000" ) else 
	 slv_reg201 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011001001" ) else 
	 slv_reg202 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011001010" ) else 
	 slv_reg203 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011001011" ) else 
	 slv_reg204 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011001100" ) else 
	 slv_reg205 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011001101" ) else 
	 slv_reg206 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011001110" ) else 
	 slv_reg207 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011001111" ) else 
	 slv_reg208 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011010000" ) else 
	 slv_reg209 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011010001" ) else 
	 slv_reg210 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011010010" ) else 
	 slv_reg211 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011010011" ) else 
	 slv_reg212 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011010100" ) else 
	 slv_reg213 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011010101" ) else 
	 slv_reg214 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011010110" ) else 
	 slv_reg215 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011010111" ) else 
	 slv_reg216 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011011000" ) else 
	 slv_reg217 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011011001" ) else 
	 slv_reg218 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011011010" ) else 
	 slv_reg219 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011011011" ) else 
	 slv_reg220 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011011100" ) else 
	 slv_reg221 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011011101" ) else 
	 slv_reg222 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011011110" ) else 
	 slv_reg223 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011011111" ) else 
	 slv_reg224 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011100000" ) else 
	 slv_reg225 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011100001" ) else 
	 slv_reg226 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011100010" ) else 
	 slv_reg227 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011100011" ) else 
	 slv_reg228 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011100100" ) else 
	 slv_reg229 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011100101" ) else 
	 slv_reg230 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011100110" ) else 
	 slv_reg231 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011100111" ) else 
	 slv_reg232 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011101000" ) else 
	 slv_reg233 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011101001" ) else 
	 slv_reg234 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011101010" ) else 
	 slv_reg235 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011101011" ) else 
	 slv_reg236 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011101100" ) else 
	 slv_reg237 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011101101" ) else 
	 slv_reg238 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011101110" ) else 
	 slv_reg239 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011101111" ) else 
	 slv_reg240 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011110000" ) else 
	 slv_reg241 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011110001" ) else 
	 slv_reg242 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011110010" ) else 
	 slv_reg243 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011110011" ) else 
	 slv_reg244 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011110100" ) else 
	 slv_reg245 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011110101" ) else 
	 slv_reg246 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011110110" ) else 
	 slv_reg247 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011110111" ) else 
	 slv_reg248 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011111000" ) else 
	 slv_reg249 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011111001" ) else 
	 slv_reg250 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011111010" ) else 
	 slv_reg251 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011111011" ) else 
	 slv_reg252 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011111100" ) else 
	 slv_reg253 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011111101" ) else 
	 slv_reg254 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011111110" ) else 
	 slv_reg255 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "011111111" ) else 
	 slv_reg256 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100000000" ) else 
	 slv_reg257 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100000001" ) else 
	 slv_reg258 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100000010" ) else 
	 slv_reg259 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100000011" ) else 
	 slv_reg260 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100000100" ) else 
	 slv_reg261 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100000101" ) else 
	 slv_reg262 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100000110" ) else 
	 slv_reg263 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100000111" ) else 
	 slv_reg264 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100001000" ) else 
	 slv_reg265 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100001001" ) else 
	 slv_reg266 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100001010" ) else 
	 slv_reg267 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100001011" ) else 
	 slv_reg268 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100001100" ) else 
	 slv_reg269 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100001101" ) else 
	 slv_reg270 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100001110" ) else 
	 slv_reg271 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100001111" ) else 
	 slv_reg272 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100010000" ) else 
	 slv_reg273 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100010001" ) else 
	 slv_reg274 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100010010" ) else 
	 slv_reg275 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100010011" ) else 
	 slv_reg276 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100010100" ) else 
	 slv_reg277 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100010101" ) else 
	 slv_reg278 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100010110" ) else 
	 slv_reg279 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100010111" ) else 
	 slv_reg280 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100011000" ) else 
	 slv_reg281 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100011001" ) else 
	 slv_reg282 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100011010" ) else 
	 slv_reg283 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100011011" ) else 
	 slv_reg284 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100011100" ) else 
	 slv_reg285 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100011101" ) else 
	 slv_reg286 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100011110" ) else 
	 slv_reg287 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100011111" ) else 
	 slv_reg288 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100100000" ) else 
	 slv_reg289 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100100001" ) else 
	 slv_reg290 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100100010" ) else 
	 slv_reg291 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100100011" ) else 
	 slv_reg292 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100100100" ) else 
	 slv_reg293 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100100101" ) else 
	 slv_reg294 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100100110" ) else 
	 slv_reg295 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100100111" ) else 
	 slv_reg296 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100101000" ) else 
	 slv_reg297 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100101001" ) else 
	 slv_reg298 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100101010" ) else 
	 slv_reg299 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100101011" ) else 
	 slv_reg300 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100101100" ) else 
	 slv_reg301 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100101101" ) else 
	 slv_reg302 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100101110" ) else 
	 slv_reg303 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100101111" ) else 
	 slv_reg304 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100110000" ) else 
	 slv_reg305 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100110001" ) else 
	 slv_reg306 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100110010" ) else 
	 slv_reg307 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100110011" ) else 
	 slv_reg308 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100110100" ) else 
	 slv_reg309 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100110101" ) else 
	 slv_reg310 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100110110" ) else 
	 slv_reg311 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100110111" ) else 
	 slv_reg312 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100111000" ) else 
	 slv_reg313 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100111001" ) else 
	 slv_reg314 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100111010" ) else 
	 slv_reg315 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100111011" ) else 
	 slv_reg316 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100111100" ) else 
	 slv_reg317 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100111101" ) else 
	 slv_reg318 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100111110" ) else 
	 slv_reg319 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "100111111" ) else 
	 slv_reg320 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101000000" ) else 
	 slv_reg321 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101000001" ) else 
	 slv_reg322 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101000010" ) else 
	 slv_reg323 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101000011" ) else 
	 slv_reg324 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101000100" ) else 
	 slv_reg325 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101000101" ) else 
	 slv_reg326 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101000110" ) else 
	 slv_reg327 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101000111" ) else 
	 slv_reg328 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101001000" ) else 
	 slv_reg329 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101001001" ) else 
	 slv_reg330 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101001010" ) else 
	 slv_reg331 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101001011" ) else 
	 slv_reg332 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101001100" ) else 
	 slv_reg333 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101001101" ) else 
	 slv_reg334 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101001110" ) else 
	 slv_reg335 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101001111" ) else 
	 slv_reg336 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101010000" ) else 
	 slv_reg337 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101010001" ) else 
	 slv_reg338 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101010010" ) else 
	 slv_reg339 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101010011" ) else 
	 slv_reg340 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101010100" ) else 
	 slv_reg341 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101010101" ) else 
	 slv_reg342 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101010110" ) else 
	 slv_reg343 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101010111" ) else 
	 slv_reg344 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101011000" ) else 
	 slv_reg345 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101011001" ) else 
	 slv_reg346 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101011010" ) else 
	 slv_reg347 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101011011" ) else 
	 slv_reg348 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101011100" ) else 
	 slv_reg349 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101011101" ) else 
	 slv_reg350 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101011110" ) else 
	 slv_reg351 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101011111" ) else 
	 slv_reg352 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101100000" ) else 
	 slv_reg353 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101100001" ) else 
	 slv_reg354 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101100010" ) else 
	 slv_reg355 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101100011" ) else 
	 slv_reg356 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101100100" ) else 
	 slv_reg357 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101100101" ) else 
	 slv_reg358 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101100110" ) else 
	 slv_reg359 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101100111" ) else 
	 slv_reg360 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101101000" ) else 
	 slv_reg361 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101101001" ) else 
	 slv_reg362 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101101010" ) else 
	 slv_reg363 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101101011" ) else 
	 slv_reg364 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101101100" ) else 
	 slv_reg365 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101101101" ) else 
	 slv_reg366 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101101110" ) else 
	 slv_reg367 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101101111" ) else 
	 slv_reg368 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101110000" ) else 
	 slv_reg369 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101110001" ) else 
	 slv_reg370 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101110010" ) else 
	 slv_reg371 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101110011" ) else 
	 slv_reg372 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101110100" ) else 
	 slv_reg373 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101110101" ) else 
	 slv_reg374 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101110110" ) else 
	 slv_reg375 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101110111" ) else 
	 slv_reg376 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101111000" ) else 
	 slv_reg377 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101111001" ) else 
	 slv_reg378 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101111010" ) else 
	 slv_reg379 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101111011" ) else 
	 slv_reg380 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101111100" ) else 
	 slv_reg381 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101111101" ) else 
	 slv_reg382 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101111110" ) else 
	 slv_reg383 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "101111111" ) else 
	 slv_reg384 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110000000" ) else 
	 slv_reg385 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110000001" ) else 
	 slv_reg386 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110000010" ) else 
	 slv_reg387 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110000011" ) else 
	 slv_reg388 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110000100" ) else 
	 slv_reg389 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110000101" ) else 
	 slv_reg390 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110000110" ) else 
	 slv_reg391 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110000111" ) else 
	 slv_reg392 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110001000" ) else 
	 slv_reg393 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110001001" ) else 
	 slv_reg394 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110001010" ) else 
	 slv_reg395 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110001011" ) else 
	 slv_reg396 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110001100" ) else 
	 slv_reg397 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110001101" ) else 
	 slv_reg398 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110001110" ) else 
	 slv_reg399 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110001111" ) else 
	 slv_reg400 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110010000" ) else 
	 slv_reg401 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110010001" ) else 
	 slv_reg402 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110010010" ) else 
	 slv_reg403 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110010011" ) else 
	 slv_reg404 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110010100" ) else 
	 slv_reg405 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110010101" ) else 
	 slv_reg406 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110010110" ) else 
	 slv_reg407 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110010111" ) else 
	 slv_reg408 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110011000" ) else 
	 slv_reg409 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110011001" ) else 
	 slv_reg410 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110011010" ) else 
	 slv_reg411 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110011011" ) else 
	 slv_reg412 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110011100" ) else 
	 slv_reg413 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110011101" ) else 
	 slv_reg414 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110011110" ) else 
	 slv_reg415 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110011111" ) else 
	 slv_reg416 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110100000" ) else 
	 slv_reg417 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110100001" ) else 
	 slv_reg418 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110100010" ) else 
	 slv_reg419 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110100011" ) else 
	 slv_reg420 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110100100" ) else 
	 slv_reg421 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110100101" ) else 
	 slv_reg422 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110100110" ) else 
	 slv_reg423 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110100111" ) else 
	 slv_reg424 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110101000" ) else 
	 slv_reg425 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110101001" ) else 
	 slv_reg426 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110101010" ) else 
	 slv_reg427 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110101011" ) else 
	 slv_reg428 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110101100" ) else 
	 slv_reg429 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110101101" ) else 
	 slv_reg430 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110101110" ) else 
	 slv_reg431 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110101111" ) else 
	 slv_reg432 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110110000" ) else 
	 slv_reg433 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110110001" ) else 
	 slv_reg434 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110110010" ) else 
	 slv_reg435 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110110011" ) else 
	 slv_reg436 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110110100" ) else 
	 slv_reg437 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110110101" ) else 
	 slv_reg438 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110110110" ) else 
	 slv_reg439 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110110111" ) else 
	 slv_reg440 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110111000" ) else 
	 slv_reg441 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110111001" ) else 
	 slv_reg442 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110111010" ) else 
	 slv_reg443 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110111011" ) else 
	 slv_reg444 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110111100" ) else 
	 slv_reg445 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110111101" ) else 
	 slv_reg446 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110111110" ) else 
	 slv_reg447 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "110111111" ) else 
	 slv_reg448 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111000000" ) else 
	 slv_reg449 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111000001" ) else 
	 slv_reg450 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111000010" ) else 
	 slv_reg451 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111000011" ) else 
	 slv_reg452 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111000100" ) else 
	 slv_reg453 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111000101" ) else 
	 slv_reg454 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111000110" ) else 
	 slv_reg455 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111000111" ) else 
	 slv_reg456 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111001000" ) else 
	 slv_reg457 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111001001" ) else 
	 slv_reg458 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111001010" ) else 
	 slv_reg459 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111001011" ) else 
	 slv_reg460 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111001100" ) else 
	 slv_reg461 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111001101" ) else 
	 slv_reg462 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111001110" ) else 
	 slv_reg463 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111001111" ) else 
	 slv_reg464 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111010000" ) else 
	 slv_reg465 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111010001" ) else 
	 slv_reg466 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111010010" ) else 
	 slv_reg467 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111010011" ) else 
	 slv_reg468 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111010100" ) else 
	 slv_reg469 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111010101" ) else 
	 slv_reg470 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111010110" ) else 
	 slv_reg471 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111010111" ) else 
	 slv_reg472 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111011000" ) else 
	 slv_reg473 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111011001" ) else 
	 slv_reg474 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111011010" ) else 
	 slv_reg475 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111011011" ) else 
	 slv_reg476 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111011100" ) else 
	 slv_reg477 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111011101" ) else 
	 slv_reg478 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111011110" ) else 
	 slv_reg479 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111011111" ) else 
	 slv_reg480 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111100000" ) else 
	 slv_reg481 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111100001" ) else 
	 slv_reg482 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111100010" ) else 
	 slv_reg483 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111100011" ) else 
	 slv_reg484 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111100100" ) else 
	 slv_reg485 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111100101" ) else 
	 slv_reg486 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111100110" ) else 
	 slv_reg487 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111100111" ) else 
	 slv_reg488 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111101000" ) else 
	 slv_reg489 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111101001" ) else 
	 slv_reg490 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111101010" ) else 
	 slv_reg491 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111101011" ) else 
	 slv_reg492 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111101100" ) else 
	 slv_reg493 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111101101" ) else 
	 slv_reg494 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111101110" ) else 
	 slv_reg495 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111101111" ) else 
	 slv_reg496 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111110000" ) else 
	 slv_reg497 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111110001" ) else 
	 slv_reg498 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111110010" ) else 
	 slv_reg499 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111110011" ) else 
	 slv_reg500 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111110100" ) else 
	 slv_reg501 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111110101" ) else 
	 slv_reg502 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111110110" ) else 
	 slv_reg503 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111110111" ) else 
	 slv_reg504 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111111000" ) else 
	 slv_reg505 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111111001" ) else 
	 slv_reg506 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111111010" ) else 
	 slv_reg507 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111111011" ) else 
	 slv_reg508 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111111100" ) else 
	 slv_reg509 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111111101" ) else 
	 slv_reg510 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111111110" ) else 
	 slv_reg511 when (axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB) = "111111111" ) else 
	 (others => '0');

	-- Add user logic here

	-- User logic ends

end arch_imp;
