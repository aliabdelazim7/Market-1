export type StickerArtDirection = {
  id: string;
  name: string;
  motif: string;
  icon: string;
  palette: [string, string];
  prompt: string;
};

// Curated art directions for school stickers: clear hierarchy, bold names,
// limited palettes, friendly motifs, and print-safe contrast.
export const stickerArtDirections: StickerArtDirection[] = [
  { id: 'sunny', name: 'شمس مرحة', motif: 'sunshine and soft rays', icon: '☼', palette: ['#FFC857', '#F59E0B'], prompt: 'friendly school sticker, sunny yellow, rounded organic shape, clean bold name area, no clutter' },
  { id: 'space', name: 'فضاء لطيف', motif: 'tiny planets and stars', icon: '✦', palette: ['#4338CA', '#7C3AED'], prompt: 'friendly school sticker, deep indigo and violet, tiny planets, stars, rounded badge, clean bold name area' },
  { id: 'ocean', name: 'موجة زرقاء', motif: 'small waves and bubbles', icon: '≈', palette: ['#0891B2', '#2563EB'], prompt: 'friendly school sticker, aqua blue, small wave and bubble motifs, crisp rounded label, clean bold name area' },
  { id: 'garden', name: 'حديقة صغيرة', motif: 'leaves and flowers', icon: '✿', palette: ['#059669', '#65A30D'], prompt: 'friendly school sticker, fresh green, simple leaves and flowers, rounded organic shape, clean bold name area' },
  { id: 'berry', name: 'توت مرح', motif: 'dots and playful berries', icon: '●', palette: ['#DB2777', '#9333EA'], prompt: 'friendly school sticker, berry pink and purple, playful dots, soft rounded shape, clean bold name area' },
  { id: 'coral', name: 'مرجان', motif: 'abstract coral waves', icon: '⌁', palette: ['#F97316', '#EF4444'], prompt: 'friendly school sticker, coral orange and red, abstract organic waves, clean bold name area' },
  { id: 'rainbow', name: 'قوس قزح', motif: 'rainbow arcs and dots', icon: '⌒', palette: ['#F43F5E', '#F59E0B'], prompt: 'friendly school sticker, warm rainbow accents, clean arcs and dots, rounded label, clean bold name area' },
  { id: 'mint', name: 'نعناع', motif: 'rounded bubbles and sparkles', icon: '✧', palette: ['#0F766E', '#14B8A6'], prompt: 'friendly school sticker, mint teal, rounded bubbles and subtle sparkles, clean bold name area' },
  { id: 'dino', name: 'ديناصور لطيف', motif: 'tiny dinosaur footprints', icon: '◒', palette: ['#4D7C0F', '#16A34A'], prompt: 'friendly school sticker, leafy green, tiny dinosaur footprints, no character face, clean bold name area' },
  { id: 'pink-card', name: 'كارت وردي', motif: 'قلوب ودرجات بينك', icon: '♥', palette: ['#ec4899', '#f9a8d4'], prompt: 'horizontal glossy pink school card inspired by customer references, hearts, bows, school icons, photo area and clean name fields' },
  { id: 'purple-card', name: 'كارت بنفسجي', motif: 'تاج ونجوم', icon: '♕', palette: ['#8b5cf6', '#ddd6fe'], prompt: 'horizontal glossy purple school card inspired by customer references, crown, stars, hearts, photo area and clean name fields' },
  { id: 'blue-card', name: 'كارت أزرق', motif: 'بحر وقلعة', icon: '✦', palette: ['#0284c7', '#bae6fd'], prompt: 'horizontal dreamy blue school card inspired by customer references, ocean details, castle, school supplies, photo area and clean name fields' },
  { id: 'space-card', name: 'كارت فضاء', motif: 'كواكب ورائد فضاء', icon: '✦', palette: ['#312e81', '#c084fc'], prompt: 'horizontal galaxy school card inspired by customer references, planets, stars, friendly astronaut, photo area and clean name fields' },
  { id: 'dino-card', name: 'كارت ديناصور', motif: 'مغامرة وغابة', icon: '◒', palette: ['#166534', '#60a5fa'], prompt: 'horizontal dinosaur school card inspired by customer references, friendly dinosaur, jungle, stars, photo area and clean name fields' },
  { id: 'robot', name: 'روبوت', motif: 'simple bolts and circuits', icon: '＋', palette: ['#475569', '#0EA5E9'], prompt: 'friendly school sticker, slate blue, simple bolts and circuit lines, clean bold name area' },
  { id: 'lemon', name: 'ليمون', motif: 'tiny citrus shapes', icon: '✺', palette: ['#EAB308', '#84CC16'], prompt: 'friendly school sticker, lemon yellow and lime, tiny citrus shapes, clean bold name area' },
  { id: 'cloud', name: 'سحابة', motif: 'clouds and gentle rainbows', icon: '☁', palette: ['#60A5FA', '#818CF8'], prompt: 'friendly school sticker, sky blue and lavender, clouds and gentle rainbow, clean bold name area' },
];

export const getStickerArtDirection = (seed: string) => {
  const index = Array.from(seed).reduce((sum, char) => sum + char.charCodeAt(0), 0) % stickerArtDirections.length;
  return stickerArtDirections[index];
};
