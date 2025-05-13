library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fir_filter is
    port(
        clk: in std_logic;
        rst: in std_logic;
        valid_in: in std_logic;
        x: in std_logic_vector(7 downto 0);
        valid_out: out std_logic ;
        y: out std_logic_vector(18 downto 0)
    );
end fir_filter;

architecture structural of fir_filter is
    component control_unit is
        port(
            clk: in std_logic;
            rst: in std_logic;
            valid_in: in std_logic;
            rom_addr: out std_logic_vector(2 downto 0);
            ram_addr: out std_logic_vector(2 downto 0);
            mac_init: out std_logic;
            we: out std_logic;
            valid_out: out std_logic
        );
    end component;

    component mlab_ram is
       port (
           rst  : in std_logic;
           clk  : in std_logic;
           we   : in std_logic;				--- memory write enable
           en   : in std_logic;				--- operation enable
           addr : in std_logic_vector(2 downto 0);			-- memory address
           di   : in std_logic_vector(7 downto 0);		-- input data
           do   : out std_logic_vector(7 downto 0)
        );		-- output data
   end component;

   component mlab_rom is
        Port ( 
            clk : in  STD_LOGIC;
            en : in  STD_LOGIC;				--- operation enable
            addr : in  STD_LOGIC_VECTOR (2 downto 0);			-- memory address
            rom_out : out  STD_LOGIC_VECTOR (7 downto 0)
        );	-- output data
    end component;
    
    component mac is
        port(
            init: in std_logic;
            b: in std_logic_vector(7 downto 0);
            c: in std_logic_vector(7 downto 0);
            clk: in std_logic;
            y: out std_logic_vector(18 downto 0) -- 2X + 3 bits
        );
    end component;

    signal rom_addr_s, ram_addr_s: std_logic_vector(2 downto 0);
    signal mac_init_s, r_mac_init, valid_out_s, we_s: std_logic;
    signal r_x, rom_out_s, ram_out_s: std_logic_vector(7 downto 0);
    signal r_valid_out: std_logic_vector(8 downto 0);
    signal mac_out: std_logic_vector(18 downto 0) := (others=>'0');
    
begin
    cu: control_unit port map(
        clk => clk,
        rst => rst,
        valid_in => valid_in,
        rom_addr => rom_addr_s,
        ram_addr => ram_addr_s,
        mac_init => mac_init_s,
        we => we_s,
        valid_out => valid_out_s
    );
    rom: mlab_rom port map(
        clk => clk,
        en => '1',
        addr => rom_addr_s,
        rom_out => rom_out_s
    );
    ram: mlab_ram port map(
        rst => rst,
        clk => clk,
        we  => we_s,
        en  => '1',
        addr => ram_addr_s,
        di => r_x,
        do => ram_out_s
    );
    comp_mac: mac port map(
        init => r_mac_init,
        b => rom_out_s,
        c => ram_out_s,
        clk => clk,
        y => mac_out
    );

    valid_out <= r_valid_out(8);

    sync: process(clk,rst)
    begin
        if rst = '1' then
            r_x <= (others => '0');
            r_mac_init <= '0';
            r_valid_out <= (others => '0');
        else
            if clk'event and clk='1' then
                r_x <= x;
                r_mac_init <= mac_init_s;
                r_valid_out(8 downto 1) <= r_valid_out(7 downto 0);
                r_valid_out(0) <= valid_out_s;
                --update output on valid_out
                if r_valid_out(8) = '1' then 
                    y <= mac_out;
                end if;
            end if;
        end if;
    end process;
    
end structural;
