export interface coord {
  x: number;
  y: number;
}

export interface vec {
  pos: coord;
  word: string;
  year: number;
  closest?: string;
}