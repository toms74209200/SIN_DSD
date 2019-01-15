-- =====================================================================
--  Title		: Delta-sigma converter
--
--  File Name	: DSD_CNV.vhd
--  Project		: Sample
--  Block		:
--  Tree		:
--  Designer	: T.Suzuki - HDK
--  Created		: 2017/04/25
-- =====================================================================
--	Rev.	Date		Designer	Change Description
-- ---------------------------------------------------------------------
--	v0.1	17/04/25	T.Suzuki		First
-- =====================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity DSD_CNV is
	port(
		nRST	: in	std_logic;						--(n) Reset
		CLK		: in	std_logic;						--(p) Clock

		EN		: in	std_logic;						--(p) Enable
		SEL		: in	std_logic_vector(3 downto 0);	--(p) Integer bit width select
		PDAT	: in	std_logic_vector(11 downto 0);	--(p) Vector data
		SDAT	: out	std_logic						--(p) Serial data
		);
end DSD_CNV;

architecture RTL of DSD_CNV is

signal int_a	: std_logic_vector(12 downto 0);
signal int_b	: std_logic_vector(13 downto 0);
signal int_c	: std_logic_vector(14 downto 0);
signal int_d	: std_logic_vector(15 downto 0);


begin
-- ***********************************************************
--	Integrate
-- ***********************************************************
process (CLK, nRST) begin
	if (nRST = '0') then
		int_a <= (others => '0');
	elsif (CLK'event and CLK = '1') then
		if (SEL = "0001") then
			if (EN = '1') then
				int_a <= ('0' & int_a(11 downto 0)) + ('0' & PDAT);
			else
				int_a <= (others => '0');
			end if;
		end if;
	end if;
end process;

process (CLK, nRST) begin
	if (nRST = '0') then
		int_b <= (others => '0');
	elsif (CLK'event and CLK = '1') then
		if (SEL = "0010") then
			if (EN = '1') then
				int_b <= ('0' & int_b(12 downto 0)) + ("00" & PDAT);
			else
				int_b <= (others => '0');
			end if;
		end if;
	end if;
end process;

process (CLK, nRST) begin
	if (nRST = '0') then
		int_c <= (others => '0');
	elsif (CLK'event and CLK = '1') then
		if (SEL = "0100") then
			if (EN = '1') then
				int_c <= ('0' & int_c(13 downto 0)) + ("000" & PDAT);
			else
				int_c <= (others => '0');
			end if;
		end if;
	end if;
end process;

process (CLK, nRST) begin
	if (nRST = '0') then
		int_d <= (others => '0');
	elsif (CLK'event and CLK = '1') then
		if (SEL = "1000") then
			if (EN = '1') then
				int_d <= ('0' & int_d(14 downto 0)) + ("0000" & PDAT);
			else
				int_d <= (others => '0');
			end if;
		end if;
	end if;
end process;

SDAT <= int_a(12) when (SEL(0) = '1') else
		int_b(13) when (SEL(1) = '1') else
		int_c(14) when (SEL(2) = '1') else
		int_d(15);

end RTL; --SIN_GEN
