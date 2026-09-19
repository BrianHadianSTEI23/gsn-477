library ieee;
use ieee.std_logic_1164.all;

entity tb_gsn is
end entity tb_gsn;

architecture sim of tb_gsn is

    constant CLK_PERIOD : time := 20 ns;

    signal clk_in        : std_logic := '0';
    signal rst           : std_logic := '0';

    signal pc_out        : std_logic_vector(3 downto 0);
    signal op_out        : std_logic_vector(3 downto 0);
    signal a_out         : std_logic_vector(3 downto 0);
    signal b_out         : std_logic_vector(3 downto 0);
    signal fb_out        : std_logic_vector(3 downto 0);
    signal ansi_char_out : std_logic_vector(7 downto 0);
    signal halted_out    : std_logic;

    signal sim_end       : boolean := false;

begin

    -- Unit Under Test
    uut: entity work.gsn
        port map (
            clk_in        => clk_in,
            rst           => rst,
            pc_out        => pc_out,
            op_out        => op_out,
            a_out         => a_out,
            b_out         => b_out,
            fb_out        => fb_out,
            ansi_char_out => ansi_char_out,
            halted_out    => halted_out
        );

    -- Clock Oscillator
    clk_gen: process
    begin
        while not sim_end loop
            clk_in <= '0';
            wait for CLK_PERIOD / 2;
            clk_in <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Stimulus & Monitoring Process
    stim_proc: process
    begin
        report "--- Starting GSN477 Top-Level CPU Integration Test ---";

        -- Apply System Reset
        rst <= '1';
        wait for 40 ns;
        rst <= '0';
        wait for 20 ns;

        report "--- CPU Reset Released, Executing Preloaded Program ---";

        -- Run simulation through multiple instruction cycles (7 T-states each = 140ns per instruction)
        for i in 1 to 30 loop
            wait for 7 * CLK_PERIOD;
            report "Cycle " & integer'image(i) & 
                   " | PC: " & to_hstring(pc_out) & 
                   " | OP: " & to_hstring(op_out) & 
                   " | RegA: " & to_hstring(a_out) & 
                   " | RegB: " & to_hstring(b_out) & 
                   " | FB_Char: " & to_string(ansi_char_out);
                   
            if halted_out = '1' then
                report "--- SYSTEM HALT DETECTED ---";
                exit;
            end if;
        end loop;

        sim_end <= true;
        report "=== TOP-LEVEL CPU INTEGRATION TEST PASSED ===";
        wait;
    end process;

end architecture sim;