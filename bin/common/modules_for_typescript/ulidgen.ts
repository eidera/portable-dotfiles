#! /usr/bin/env anode ts-node

// Prepareation
//   npm install -g id128
// 
// Execution
//   export NODE_PATH=$(npm bin -g)../lib/node_modules
//   node ulidgen.js

const { Ulid, Uuid } = require('id128')

const WAIT_MSEC = 5 // [msec] // ULIDの昇順を保証させるためのウェイト [msec] 。1[msec] 以上であれば問題はないはず

async function sleep (waitMsec: number): Promise<void> {
  return new Promise<void>((resolve, _reject) => {
    setTimeout(() => {
      resolve()
    }, waitMsec)
  });
}

function generateUuid(): string {
  return Uuid.fromRaw(Ulid.generate().toRaw()).toCanonical().toLowerCase()
}

async function main(argv: string[]) {
  // 引数が指定されていたら3番目(index: 2)のもののみ使用する
  const count: number = (argv.length > 2) ? parseInt(argv[2], 10) : 1

  for (let i = 0; i < count; i++) {
    await sleep(WAIT_MSEC)
    console.log(generateUuid())
  }
}

main(process.argv)
