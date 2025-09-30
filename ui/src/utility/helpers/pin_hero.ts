import { Transaction } from "@mysten/sui/transactions";

export const pinHero = (
packageId: string,
heroId: string,
) => {
  const tx = new Transaction();

  tx.moveCall({
    target: `${packageId}::hero::pin_hero`,
    arguments: [tx.object(heroId)],
  });
 
 return tx;
};