-- =====================================================================
--  Title		: SIN waveform genarater
--
--  File Name	: SIN_GEN.vhd
--  Project		: Sample
--  Block		:
--  Tree		:
--  Designer	: T.Suzuki - HDK
--  Created		: 2017/04/19
-- =====================================================================
--	Rev.	Date		Designer	Change Description
-- ---------------------------------------------------------------------
--	v0.1	17/04/19	T.Suzuki		First
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity SIN_GEN is
	port(
		nRST	: in	std_logic;						--(n) Reset
		CLK		: in	std_logic;						--(p) Clock

		EN		: in	std_logic;						--(p) Enable
		RATIO	: in	std_logic_vector(3 downto 0);	--(p) Frequency ratio
		DAT		: out	std_logic_vector(11 downto 0)	--(p) Data
		);
end SIN_GEN;

architecture RTL of SIN_GEN is

signal	dec_cnt		: std_logic_vector(3 downto 0);
signal	dec_pls_i	: std_logic;
signal	dat_cnt		: integer range 0 to 124;
signal	phs_cnt		: std_logic_vector(1 downto 0);
signal	dat_i		: std_logic_vector(11 downto 0);

constant cnt_end	: integer := 124;


type RamType is array(0 to 124) of std_logic_vector(11 downto 0);
signal RAM : RamType;
attribute ram_init_file : string;
attribute ram_init_file of RAM :
signal is "SIN_TBL.mif";

begin

-- ***********************************************************
--	Decimation counter
-- ***********************************************************
process (CLK, nRST) begin
	if (nRST = '0') then
		dec_cnt <= (others => '0');
	elsif (CLK'event and CLK = '1') then
		if (EN = '1') then
			if (dec_cnt = RATIO) then
				dec_cnt <= (others => '0');
			else
				dec_cnt <= dec_cnt + 1;
			end if;
		else
			dec_cnt <= (others => '0');
		end if;
	end if;
end process;

dec_pls_i <= '1' when (dec_cnt = RATIO) else '0';


-- ***********************************************************
--	Data counter
-- ***********************************************************
process (CLK, nRST) begin
	if (nRST = '0') then
		dat_cnt <= 0;
	elsif (CLK'event and CLK = '1') then
		if (EN = '1') then
			if (RATIO = 0) then
				if (dat_cnt = cnt_end) then
					dat_cnt <= 0;
				else
					dat_cnt <= dat_cnt + 1;
				end if;
			else
				if (dec_pls_i = '1') then
					if (dat_cnt = cnt_end) then
						dat_cnt <= 0;
					else
						dat_cnt <= dat_cnt + 1;
					end if;
				end if;
			end if;
		else
			dat_cnt <= 0;
		end if;
	end if;
end process;


-- ***********************************************************
--	Data counter
-- ***********************************************************
process (CLK, nRST) begin
	if (nRST = '0') then
		phs_cnt <= (others => '0');
	elsif (CLK'event and CLK = '1') then
		if (EN = '1') then
			if (dat_cnt = cnt_end) then
				if (RATIO = 0) then
					if (phs_cnt = 3) then
						phs_cnt <= (others => '0');
					else
						phs_cnt <= phs_cnt + 1;
					end if;
				else
					if (dec_pls_i = '1') then
						if (phs_cnt = 3) then
							phs_cnt <= (others => '0');
						else
							phs_cnt <= phs_cnt + 1;
						end if;
					end if;
				end if;
			end if;
		else
			phs_cnt <= (others => '0');
		end if;
	end if;
end process;


-- ***********************************************************
--	Data
-- ***********************************************************
process (CLK, nRST) begin
	if (nRST = '0') then
		dat_i <= (others => '0');
	elsif (CLK'event and CLK = '1') then
		if (EN = '1') then
			if (phs_cnt = 0) then
				dat_i <= RAM(dat_cnt);
			elsif (phs_cnt = 1) then
				dat_i <= RAM(cnt_end - dat_cnt);
			elsif (phs_cnt = 2) then
				dat_i <= not RAM(dat_cnt);
			else
				dat_i <= not RAM(cnt_end - dat_cnt);
			end if;
		else
			dat_i <= (others => '0');
		end if;
	end if;
end process;

DAT <= dat_i;


-- Output SIN signal frequency --
-- = fclk /(4 * signal table length(RAM word num) * (ratio + 1))

end RTL; --SIN_GEN
