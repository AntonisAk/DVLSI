library ieee;
use ieee.std_logic_1164.all;

entity mul_syst is
    port(
        a: in std_logic_vector(3 downto 0);
        b: in std_logic_vector(3 downto 0);
        clk: in std_logic;
        p: out std_logic_vector(7 downto 0)
    );
end mul_syst;

architecture mul_syst_arch of mul_syst is
    component mul_cell is
        port(
        ain: in std_logic;
        bin: in std_logic;
        cin: in std_logic;
        sin: in std_logic;
        clk: in std_logic;
        aout: out std_logic;
        bout: out std_logic;
        cout: out std_logic;
        sout: out std_logic
    );
    end component;

    -- signals
    signal ai, bi, ci, si, ao, bo, co, so: std_logic_vector(15 downto 0);

    -- horizontal registers (by levels of deep)
    signal r_b1: std_logic_vector(1 downto 0);
    signal r_b2: std_logic_vector(3 downto 0);
    signal r_b3: std_logic_vector(5 downto 0);

    -- diagonal registers (by levels of deep)
    signal r_d1: std_logic_vector(2 downto 0);
    signal r_d2: std_logic_vector(1 downto 0);
    signal r_d3: std_logic;

    -- outer carry register (gtsm)
    signal rc: std_logic_vector(2 downto 0);

    -- vertical register array (by bit position)
    type reg_array is array (0 to 5) of std_logic_vector(8 downto 0);
    signal r: reg_array;

begin
    --pipeline gtsm (c outer)
    pipeline_outer: process(clk)
    begin
        if clk'event and clk='1' then
            rc <= co(11) & co(7) & co(3);
        end if;
    end process;

    --pipeline diagonal (a)
    pipeline_diag: process(clk)
    begin
        if clk'event and clk='1' then
            r_d3 <= r_d2(1);
            r_d2 <= r_d1(2 downto 1);
            r_d1 <= a(3 downto 1);
        end if;
    end process;

    --pipeline horizontal (b)
    pipeline_hor: process(clk)
    begin
        if clk'event and clk='1' then
            for i in 5 downto 1 loop
                r_b3(i) <= r_b3(i-1);
            end loop;
            r_b3(0) <= b(3);

            for i in 3 downto 1 loop
                r_b2(i) <= r_b2(i-1);
            end loop;
            r_b2(0) <= b(2);

            r_b1(1) <= r_b1(0);
            r_b1(0) <= b(1);
        end if;
    end process;

    -- pipeline vertical
    pipeline_vert: process(clk)
    begin
        if clk'event and clk='1' then
            for ii in 0 to 5 loop
                for jj in 8 downto 1 loop
                    r(ii)(jj) <= r(ii)(jj-1);
                end loop;
                if ii < 3 then
                    r(ii)(0) <= so(4*ii);
                else
                    r(ii)(0) <= so(9+ii);
                end if;
            end loop;
        end if;
    end process;

    -- cells init
    ginit: for i in 0 to 15 generate
        gcell: mul_cell port map(ai(i), bi(i), ci(i), si(i), clk, ao(i), bo(i), co(i), so(i));
    end generate;

    -- inter wires
    ga: for i in 4 to 15 generate
       ai(i) <= ao(i-4);         
    end generate;
    
    ci(0) <= '0';
    ci(4) <= '0';
    ci(8) <= '0';
    ci(12) <= '0';
    gbci: for i in 0 to 3 generate
        gbcj: for j in 1 to 3 generate
            bi(4*i+j) <= bo(4*i+j-1);
            ci(4*i+j) <= co(4*i+j-1);
        end generate;
    end generate;
    
    si(3 downto 0) <= "0000";
    gs: for i in 1 to 3 generate
        si(4*i) <= so(4*(i-1)+1);
        si(4*i+1) <= so(4*(i-1)+2);
        si(4*i+2) <= so(4*(i-1)+3);
        si(4*i+3) <= rc(i-1);
    end generate;

    -- input
    ai(0) <= a(0);
    ai(1) <= r_d1(0);
    ai(2) <= r_d2(0);
    ai(3) <= r_d3;
    bi(0) <= b(0);
    bi(4) <= r_b1(1);
    bi(8) <= r_b2(3);
    bi(12) <= r_b3(5);

    -- result
    p <= co(15) & so(15) & r(5)(0) & r(4)(1) & r(3)(2) & r(2)(4) & r(1)(6) & r(0)(8);
end mul_syst_arch;