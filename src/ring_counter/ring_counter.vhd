library ieee;
use ieee.std_logic_1164.all;

entity ring_counter is
    port (
        clk   : in  std_logic;                    -- System clock
        rst   : in  std_logic;                    -- Global reset (active high)
        t_out : out std_logic_vector(6 downto 0)  -- 7-bit one-hot T-state vector (T1 to T7)
    );
end entity ring_counter;

architecture behavioral of ring_counter is
    signal t_reg : std_logic_vector(6 downto 0) := "0000001";
begin

    process(clk, rst)
    begin
        if rst = '1' then
            t_reg <= "0000001"; -- Reset to T1 state
        elsif rising_edge(clk) then
            -- Rotate left: bit 6 wraps around to bit 0
            t_reg <= t_reg(5 downto 0) & t_reg(6);
        end if;
    end process;

    t_out <= t_reg;

end architecture behavioral;