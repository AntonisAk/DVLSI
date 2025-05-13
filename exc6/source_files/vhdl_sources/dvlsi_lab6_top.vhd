library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dvlsi_lab6_top is
  port (
        DDR_cas_n         : inout STD_LOGIC;
        DDR_cke           : inout STD_LOGIC;
        DDR_ck_n          : inout STD_LOGIC;
        DDR_ck_p          : inout STD_LOGIC;
        DDR_cs_n          : inout STD_LOGIC;
        DDR_reset_n       : inout STD_LOGIC;
        DDR_odt           : inout STD_LOGIC;
        DDR_ras_n         : inout STD_LOGIC;
        DDR_we_n          : inout STD_LOGIC;
        DDR_ba            : inout STD_LOGIC_VECTOR( 2 downto 0);
        DDR_addr          : inout STD_LOGIC_VECTOR(14 downto 0);
        DDR_dm            : inout STD_LOGIC_VECTOR( 3 downto 0);
        DDR_dq            : inout STD_LOGIC_VECTOR(31 downto 0);
        DDR_dqs_n         : inout STD_LOGIC_VECTOR( 3 downto 0);
        DDR_dqs_p         : inout STD_LOGIC_VECTOR( 3 downto 0);
        FIXED_IO_mio      : inout STD_LOGIC_VECTOR(53 downto 0);
        FIXED_IO_ddr_vrn  : inout STD_LOGIC;
        FIXED_IO_ddr_vrp  : inout STD_LOGIC;
        FIXED_IO_ps_srstb : inout STD_LOGIC;
        FIXED_IO_ps_clk   : inout STD_LOGIC;
        FIXED_IO_ps_porb  : inout STD_LOGIC
       );
end entity; -- dvlsi_lab6_top

architecture arch of dvlsi_lab6_top is

  component design_1_wrapper is
    port (
          DDR_cas_n         : inout STD_LOGIC;
          DDR_cke           : inout STD_LOGIC;
          DDR_ck_n          : inout STD_LOGIC;
          DDR_ck_p          : inout STD_LOGIC;
          DDR_cs_n          : inout STD_LOGIC;
          DDR_reset_n       : inout STD_LOGIC;
          DDR_odt           : inout STD_LOGIC;
          DDR_ras_n         : inout STD_LOGIC;
          DDR_we_n          : inout STD_LOGIC;
          DDR_ba            : inout STD_LOGIC_VECTOR( 2 downto 0);
          DDR_addr          : inout STD_LOGIC_VECTOR(14 downto 0);
          DDR_dm            : inout STD_LOGIC_VECTOR( 3 downto 0);
          DDR_dq            : inout STD_LOGIC_VECTOR(31 downto 0);
          DDR_dqs_n         : inout STD_LOGIC_VECTOR( 3 downto 0);
          DDR_dqs_p         : inout STD_LOGIC_VECTOR( 3 downto 0);
          FIXED_IO_mio      : inout STD_LOGIC_VECTOR(53 downto 0);
          FIXED_IO_ddr_vrn  : inout STD_LOGIC;
          FIXED_IO_ddr_vrp  : inout STD_LOGIC;
          FIXED_IO_ps_srstb : inout STD_LOGIC;
          FIXED_IO_ps_clk   : inout STD_LOGIC;
          FIXED_IO_ps_porb  : inout STD_LOGIC;
          --------------------------------------------------------------------------
          ----------------------------------------------- PL (FPGA) COMMON INTERFACE
          ACLK                                : out STD_LOGIC;
          ARESETN                             : out STD_LOGIC_VECTOR(0 to 0);
          ------------------------------------------------------------------------------------
          -- PS2PL-DMA AXI4-STREAM MASTER INTERFACE TO ACCELERATOR AXI4-STREAM SLAVE INTERFACE
          M_AXIS_TO_ACCELERATOR_tdata         : out STD_LOGIC_VECTOR(7 downto 0);
          M_AXIS_TO_ACCELERATOR_tkeep         : out STD_LOGIC_VECTOR( 0    to 0);
          M_AXIS_TO_ACCELERATOR_tlast         : out STD_LOGIC;
          M_AXIS_TO_ACCELERATOR_tready        : in  STD_LOGIC;
          M_AXIS_TO_ACCELERATOR_tvalid        : out STD_LOGIC;
          ------------------------------------------------------------------------------------
          -- ACCELERATOR AXI4-STREAM MASTER INTERFACE TO PL2P2-DMA AXI4-STREAM SLAVE INTERFACE
          S_AXIS_S2MM_FROM_ACCELERATOR_tdata  : in  STD_LOGIC_VECTOR(31 downto 0);
          S_AXIS_S2MM_FROM_ACCELERATOR_tkeep  : in  STD_LOGIC_VECTOR( 3 downto 0);
          S_AXIS_S2MM_FROM_ACCELERATOR_tlast  : in  STD_LOGIC;
          S_AXIS_S2MM_FROM_ACCELERATOR_tready : out STD_LOGIC;
          S_AXIS_S2MM_FROM_ACCELERATOR_tvalid : in  STD_LOGIC
         );
  end component design_1_wrapper;

  component debayering_filter is
    generic( N : integer := 1024);
    port(
        clk         : in std_logic;
        rst_n       : in std_logic; -- Negative logic
        new_image   : in std_logic;
        valid_in    : in std_logic; 
        pixel       : in std_logic_vector(7 downto 0); 
        image_finished  : out std_logic;
        valid_out   : out std_logic; 
        R           : out std_logic_vector(7 downto 0); 
        G           : out std_logic_vector(7 downto 0); 
        B           : out std_logic_vector(7 downto 0)
    );
  end component;

-------------------------------------------
-- INTERNAL SIGNAL & COMPONENTS DECLARATION

  signal aclk    : std_logic;
  signal aresetn : std_logic_vector(0 to 0);

  signal rcv_tdata  : std_logic_vector(31 downto 0) := (others => '0');
  signal rcv_tkeep  : std_logic_vector(3 downto 0) := (others => '1'); -- Always 1
  signal rcv_tlast  : std_logic := '0';
  signal rcv_tready : std_logic := '0';
  signal rcv_tvalid : std_logic := '0';
  
  signal trm_tdata  : std_logic_vector(7 downto 0) := (others => '0');
  signal trm_tkeep  : std_logic_vector(0 to 0) := (others => '0');
  signal trm_tlast  : std_logic := '0';
  signal trm_tready : std_logic := '1'; -- Always 1
  signal trm_tvalid : std_logic := '0';

  signal s_new_image: std_logic := '0';
  signal init_flag  : std_logic := '1';
  signal valid_in   : std_logic;
    
begin
  trm_tready <= '1';  
  rcv_tkeep <= (others => '1');

  PROCESSING_SYSTEM_INSTANCE : design_1_wrapper
    port map (
              DDR_cas_n         => DDR_cas_n,
              DDR_cke           => DDR_cke,
              DDR_ck_n          => DDR_ck_n,
              DDR_ck_p          => DDR_ck_p,
              DDR_cs_n          => DDR_cs_n,
              DDR_reset_n       => DDR_reset_n,
              DDR_odt           => DDR_odt,
              DDR_ras_n         => DDR_ras_n,
              DDR_we_n          => DDR_we_n,
              DDR_ba            => DDR_ba,
              DDR_addr          => DDR_addr,
              DDR_dm            => DDR_dm,
              DDR_dq            => DDR_dq,
              DDR_dqs_n         => DDR_dqs_n,
              DDR_dqs_p         => DDR_dqs_p,
              FIXED_IO_mio      => FIXED_IO_mio,
              FIXED_IO_ddr_vrn  => FIXED_IO_ddr_vrn,
              FIXED_IO_ddr_vrp  => FIXED_IO_ddr_vrp,
              FIXED_IO_ps_srstb => FIXED_IO_ps_srstb,
              FIXED_IO_ps_clk   => FIXED_IO_ps_clk,
              FIXED_IO_ps_porb  => FIXED_IO_ps_porb,
              --------------------------------------------------------------------------
              ----------------------------------------------- PL (FPGA) COMMON INTERFACE
              ACLK                                => aclk,    -- clock to accelerator
              ARESETN                             => aresetn, -- reset to accelerator, active low
              
              
              
              ------------------------------------------------------------------------------------
              -- PS2PL-DMA AXI4-STREAM MASTER INTERFACE TO ACCELERATOR AXI4-STREAM SLAVE INTERFACE
              M_AXIS_TO_ACCELERATOR_tdata         => trm_tdata,
              M_AXIS_TO_ACCELERATOR_tkeep         => trm_tkeep,
              M_AXIS_TO_ACCELERATOR_tlast         => trm_tlast,
              M_AXIS_TO_ACCELERATOR_tready        => trm_tready,
              M_AXIS_TO_ACCELERATOR_tvalid        => trm_tvalid,
              
              
              
              
              ------------------------------------------------------------------------------------
              -- ACCELERATOR AXI4-STREAM MASTER INTERFACE TO PL2P2-DMA AXI4-STREAM SLAVE INTERFACE
              S_AXIS_S2MM_FROM_ACCELERATOR_tdata  => rcv_tdata,
              S_AXIS_S2MM_FROM_ACCELERATOR_tkeep  => rcv_tkeep,
              S_AXIS_S2MM_FROM_ACCELERATOR_tlast  => rcv_tlast,
              S_AXIS_S2MM_FROM_ACCELERATOR_tready => rcv_tready,
              S_AXIS_S2MM_FROM_ACCELERATOR_tvalid => rcv_tvalid
             );

----------------------------
-- COMPONENTS INSTANTIATIONS

FILTER_INST:
    debayering_filter
        port map(
            clk         => aclk,
            rst_n       => aresetn(0),
            new_image   => s_new_image,
            valid_in    => trm_tvalid,
            pixel       => trm_tdata,
            image_finished  => rcv_tlast,
            valid_out   => rcv_tvalid,
            R           => rcv_tdata(23 downto 16),
            G           => rcv_tdata(15 downto 8),
            B           => rcv_tdata(7 downto 0)
        );
        
        s_new_image <= trm_tvalid and init_flag;
        
        process (aclk)
        begin
            if rising_edge(aclk) then
                if trm_tvalid = '1' then
                    init_flag <= '0'; 
                end if;
            end if;
        end process;
        
end architecture; -- arch