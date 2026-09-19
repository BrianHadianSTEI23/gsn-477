library ieee;
use ieee.std_logic_1164.all;

entity clock is
    port (
        clk_in  : in  std_logic;  -- Primary oscillator input
        rst     : in  std_logic;  -- Global reset (active high)
        hlt     : in  std_logic;  -- Halt signal from opcode decoder
        clk_out : out std_logic   -- Gated system clock output
    );
end entity clock;

architecture behavioral of clock is
    signal halted : std_logic := '0';
begin

    process(clk_in, rst)
    begin
        if rst = '1' then
            halted <= '0';
        elsif rising_edge(clk_in) then
            if hlt = '1' then
                halted <= '1';
            end if;
        end if;
    end process;

    -- Gate the output clock: stopped when halted or reset
    clk_out <= clk_in and (not halted) and (not rst);

end architecture behavioral;