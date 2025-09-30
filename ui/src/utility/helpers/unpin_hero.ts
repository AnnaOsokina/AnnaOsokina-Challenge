import { Transaction } from "@mysten/sui/transactions";

export const unpinHero = (
packageId: string,
heroId: string,
) => {
  const tx = new Transaction();

  tx.moveCall({
    target: `${packageId}::hero::unpin_hero`,
    arguments: [tx.object(heroId)],
  });
 
 return tx;
};