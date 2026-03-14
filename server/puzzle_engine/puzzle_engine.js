const { LANGUAGES } = require('../config/constants');

/**
 * Server-side puzzle engine. Manages puzzle database and validation.
 * Never sends answers to client — all validation happens server-side.
 */
class PuzzleEngine {
  constructor() {
    this.puzzles = new Map(); // language -> difficulty -> puzzles[]
    this._loadPuzzles();
  }

  get totalPuzzleCount() {
    let count = 0;
    for (const langMap of this.puzzles.values()) {
      for (const diffPuzzles of langMap.values()) {
        count += diffPuzzles.length;
      }
    }
    return count;
  }

  /**
   * Get a random puzzle for a match round.
   */
  getMatchPuzzle(language = 'en', difficulty = 'medium', excludeIds = []) {
    const langPuzzles = this.puzzles.get(language);
    if (!langPuzzles) return this._getFallbackPuzzle();

    const diffPuzzles = langPuzzles.get(difficulty) || langPuzzles.get('medium');
    if (!diffPuzzles || diffPuzzles.length === 0) return this._getFallbackPuzzle();

    const available = diffPuzzles.filter((p) => !excludeIds.includes(p.id));
    if (available.length === 0) return diffPuzzles[Math.floor(Math.random() * diffPuzzles.length)];

    return available[Math.floor(Math.random() * available.length)];
  }

  /**
   * Get the daily puzzle (deterministic based on date).
   */
  getDailyPuzzle(language = 'en') {
    const now = new Date();
    const seed = now.getUTCFullYear() * 10000 + (now.getUTCMonth() + 1) * 100 + now.getUTCDate();

    const langPuzzles = this.puzzles.get(language);
    if (!langPuzzles) return this._getFallbackPuzzle();

    const allPuzzles = [];
    for (const diffPuzzles of langPuzzles.values()) {
      allPuzzles.push(...diffPuzzles);
    }

    if (allPuzzles.length === 0) return this._getFallbackPuzzle();
    return allPuzzles[seed % allPuzzles.length];
  }

  /**
   * Validate an answer against a puzzle (server-side only).
   */
  validateAnswer(puzzleId, answer) {
    const puzzle = this._findPuzzleById(puzzleId);
    if (!puzzle) return false;

    const normalizedAnswer = answer.replace(/\s/g, '').toUpperCase();
    const normalizedWord = puzzle.word.replace(/\s/g, '').toUpperCase();
    return normalizedAnswer === normalizedWord;
  }

  /**
   * Scramble a word for sending to clients.
   */
  scrambleWord(word) {
    const normalized = word.replace(/\s/g, '').toUpperCase();
    const chars = normalized.split('');

    for (let attempt = 0; attempt < 50; attempt++) {
      for (let i = chars.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [chars[i], chars[j]] = [chars[j], chars[i]];
      }
      if (chars.join('') !== normalized) break;
    }

    return chars.join('');
  }

  /**
   * Get puzzle info safe to send to client (no answer).
   */
  getClientPuzzle(puzzle) {
    return {
      id: puzzle.id,
      scrambled: this.scrambleWord(puzzle.word),
      category: puzzle.category,
      difficulty: puzzle.difficulty,
      language: puzzle.language,
      hint: puzzle.hint || '',
      letterCount: puzzle.word.replace(/\s/g, '').length,
      wordLengths: puzzle.word.split(' ').map((w) => w.length),
    };
  }

  _findPuzzleById(id) {
    for (const langMap of this.puzzles.values()) {
      for (const diffPuzzles of langMap.values()) {
        const found = diffPuzzles.find((p) => p.id === id);
        if (found) return found;
      }
    }
    return null;
  }

  _getFallbackPuzzle() {
    return {
      id: 'fallback_1',
      word: 'PUZZLE',
      category: 'Games',
      difficulty: 'easy',
      language: 'en',
      hint: 'A word game',
    };
  }

  _loadPuzzles() {
    // English puzzles
    this._addPuzzles('en', 'easy', [
      { word: 'APPLE', category: 'Fruits' },
      { word: 'GRAPE', category: 'Fruits' },
      { word: 'LEMON', category: 'Fruits' },
      { word: 'MANGO', category: 'Fruits' },
      { word: 'PEACH', category: 'Fruits' },
      { word: 'MELON', category: 'Fruits' },
      { word: 'CHAIR', category: 'Furniture' },
      { word: 'TABLE', category: 'Furniture' },
      { word: 'COUCH', category: 'Furniture' },
      { word: 'SHELF', category: 'Furniture' },
      { word: 'HORSE', category: 'Animals' },
      { word: 'EAGLE', category: 'Animals' },
      { word: 'MOUSE', category: 'Animals' },
      { word: 'SNAKE', category: 'Animals' },
      { word: 'WHALE', category: 'Animals' },
      { word: 'TIGER', category: 'Animals' },
      { word: 'PIANO', category: 'Music' },
      { word: 'FLUTE', category: 'Music' },
      { word: 'DRUMS', category: 'Music' },
      { word: 'WATER', category: 'Nature' },
      { word: 'CLOUD', category: 'Nature' },
      { word: 'RIVER', category: 'Nature' },
      { word: 'STONE', category: 'Nature' },
      { word: 'FLAME', category: 'Nature' },
      { word: 'BREAD', category: 'Food' },
      { word: 'CREAM', category: 'Food' },
      { word: 'STEAK', category: 'Food' },
      { word: 'HOUSE', category: 'Buildings' },
      { word: 'TOWER', category: 'Buildings' },
      { word: 'BEACH', category: 'Travel' },
    ]);

    this._addPuzzles('en', 'medium', [
      { word: 'CASTLE', category: 'Buildings' },
      { word: 'DRAGON', category: 'Mythology' },
      { word: 'KNIGHT', category: 'History' },
      { word: 'WIZARD', category: 'Fantasy' },
      { word: 'TEMPLE', category: 'Buildings' },
      { word: 'GALAXY', category: 'Astronomy' },
      { word: 'ROCKET', category: 'Space' },
      { word: 'PIRATE', category: 'Adventure' },
      { word: 'JUNGLE', category: 'Nature' },
      { word: 'HARBOR', category: 'Travel' },
      { word: 'BRIDGE', category: 'Buildings' },
      { word: 'CANDLE', category: 'Objects' },
      { word: 'FOREST', category: 'Nature' },
      { word: 'GARDEN', category: 'Nature' },
      { word: 'ISLAND', category: 'Geography' },
      { word: 'MARKET', category: 'Places' },
      { word: 'MUSEUM', category: 'Culture' },
      { word: 'PALACE', category: 'Buildings' },
      { word: 'SUNSET', category: 'Nature' },
      { word: 'VIOLIN', category: 'Music' },
      { word: 'ANCHOR', category: 'Nautical' },
      { word: 'AUTUMN', category: 'Seasons' },
      { word: 'BASKET', category: 'Objects' },
      { word: 'BUTTER', category: 'Food' },
      { word: 'CAMERA', category: 'Technology' },
      { word: 'COFFEE', category: 'Drinks' },
      { word: 'DESERT', category: 'Geography' },
      { word: 'FALCON', category: 'Animals' },
      { word: 'GUITAR', category: 'Music' },
      { word: 'HAMMER', category: 'Tools' },
    ]);

    this._addPuzzles('en', 'hard', [
      { word: 'GRAND PIANO', category: 'Music' },
      { word: 'DARK KNIGHT', category: 'Movies' },
      { word: 'ELDEN RING', category: 'Video Games' },
      { word: 'NORTH STAR', category: 'Astronomy' },
      { word: 'BLACK PEARL', category: 'Movies' },
      { word: 'IRON THRONE', category: 'TV Shows' },
      { word: 'MOON LIGHT', category: 'Nature' },
      { word: 'GOLD RUSH', category: 'History' },
      { word: 'STAR WARS', category: 'Movies' },
      { word: 'WILD WEST', category: 'History' },
      { word: 'FIRE STORM', category: 'Nature' },
      { word: 'BLUE WHALE', category: 'Animals' },
      { word: 'RED DRAGON', category: 'Mythology' },
      { word: 'SWORD FISH', category: 'Animals' },
      { word: 'PALM TREE', category: 'Nature' },
      { word: 'SNOW FLAKE', category: 'Nature' },
      { word: 'THUNDER BOLT', category: 'Nature' },
      { word: 'RAIN FOREST', category: 'Nature' },
      { word: 'CORAL REEF', category: 'Nature' },
      { word: 'SAND CASTLE', category: 'Objects' },
    ]);

    // Turkish puzzles
    this._addPuzzles('tr', 'easy', [
      { word: 'ELMA', category: 'Meyveler' },
      { word: 'ARMUT', category: 'Meyveler' },
      { word: 'KIRAZ', category: 'Meyveler' },
      { word: 'LIMON', category: 'Meyveler' },
      { word: 'MASA', category: 'Mobilya' },
      { word: 'KEDI', category: 'Hayvanlar' },
      { word: 'ASLAN', category: 'Hayvanlar' },
      { word: 'KARTAL', category: 'Hayvanlar' },
      { word: 'BULUT', category: 'Doga' },
      { word: 'NEHIR', category: 'Doga' },
      { word: 'DENIZ', category: 'Doga' },
      { word: 'GITAR', category: 'Muzik' },
      { word: 'PIYANO', category: 'Muzik' },
      { word: 'KITAP', category: 'Nesneler' },
      { word: 'KALEM', category: 'Nesneler' },
    ]);

    this._addPuzzles('tr', 'medium', [
      { word: 'KELEBEK', category: 'Hayvanlar' },
      { word: 'PENGUEN', category: 'Hayvanlar' },
      { word: 'ZURAFA', category: 'Hayvanlar' },
      { word: 'MAYMUN', category: 'Hayvanlar' },
      { word: 'SARAY', category: 'Binalar' },
      { word: 'KALE', category: 'Binalar' },
      { word: 'ORMAN', category: 'Doga' },
      { word: 'VOLKAN', category: 'Doga' },
      { word: 'GEZEGEN', category: 'Uzay' },
      { word: 'YILDIZ', category: 'Uzay' },
      { word: 'KEMAN', category: 'Muzik' },
      { word: 'DAVUL', category: 'Muzik' },
      { word: 'KORSAN', category: 'Macera' },
      { word: 'SOVALYE', category: 'Tarih' },
      { word: 'BUYUCU', category: 'Fantazi' },
    ]);

    this._addPuzzles('tr', 'hard', [
      { word: 'KARA ORMAN', category: 'Doga' },
      { word: 'UZAY YOLU', category: 'Bilim Kurgu' },
      { word: 'KUZEY YILDIZI', category: 'Uzay' },
      { word: 'ALTIN CAGI', category: 'Tarih' },
      { word: 'DEMIR PERDE', category: 'Tarih' },
      { word: 'BEYAZ SARAY', category: 'Binalar' },
      { word: 'MAVI BALINA', category: 'Hayvanlar' },
      { word: 'KIZIL EJDER', category: 'Mitoloji' },
      { word: 'KAR FIRTINA', category: 'Doga' },
      { word: 'AY ISIGI', category: 'Doga' },
    ]);

    // German puzzles
    this._addPuzzles('de', 'easy', [
      { word: 'APFEL', category: 'Obst' },
      { word: 'BIRNE', category: 'Obst' },
      { word: 'TRAUBE', category: 'Obst' },
      { word: 'STUHL', category: 'Moebel' },
      { word: 'TISCH', category: 'Moebel' },
      { word: 'PFERD', category: 'Tiere' },
      { word: 'ADLER', category: 'Tiere' },
      { word: 'KATZE', category: 'Tiere' },
      { word: 'WOLKE', category: 'Natur' },
      { word: 'FLUSS', category: 'Natur' },
      { word: 'STEIN', category: 'Natur' },
      { word: 'BROT', category: 'Essen' },
      { word: 'MILCH', category: 'Essen' },
      { word: 'HAUS', category: 'Gebaeude' },
      { word: 'TURM', category: 'Gebaeude' },
    ]);

    this._addPuzzles('de', 'medium', [
      { word: 'RITTER', category: 'Geschichte' },
      { word: 'DRACHE', category: 'Mythologie' },
      { word: 'ZAUBERER', category: 'Fantasie' },
      { word: 'SCHLOSS', category: 'Gebaeude' },
      { word: 'TEMPEL', category: 'Gebaeude' },
      { word: 'GALAXIE', category: 'Weltraum' },
      { word: 'RAKETE', category: 'Weltraum' },
      { word: 'DSCHUNGEL', category: 'Natur' },
      { word: 'BRUECKE', category: 'Gebaeude' },
      { word: 'GITARRE', category: 'Musik' },
      { word: 'KAFFEE', category: 'Getraenke' },
      { word: 'KAMERA', category: 'Technik' },
      { word: 'HERBST', category: 'Jahreszeiten' },
      { word: 'GARTEN', category: 'Natur' },
      { word: 'MUSEUM', category: 'Kultur' },
    ]);

    this._addPuzzles('de', 'hard', [
      { word: 'SCHWARZER WALD', category: 'Natur' },
      { word: 'NORD STERN', category: 'Weltraum' },
      { word: 'MOND LICHT', category: 'Natur' },
      { word: 'GOLD RAUSCH', category: 'Geschichte' },
      { word: 'BLAU WAL', category: 'Tiere' },
      { word: 'ROTER DRACHE', category: 'Mythologie' },
      { word: 'SCHNEE FLOCKE', category: 'Natur' },
      { word: 'DONNER SCHLAG', category: 'Natur' },
      { word: 'REGEN WALD', category: 'Natur' },
      { word: 'SAND BURG', category: 'Objekte' },
    ]);

    // Italian puzzles
    this._addPuzzles('it', 'easy', [
      { word: 'MELA', category: 'Frutta' },
      { word: 'PERA', category: 'Frutta' },
      { word: 'LIMONE', category: 'Frutta' },
      { word: 'SEDIA', category: 'Mobili' },
      { word: 'TAVOLO', category: 'Mobili' },
      { word: 'GATTO', category: 'Animali' },
      { word: 'LEONE', category: 'Animali' },
      { word: 'AQUILA', category: 'Animali' },
      { word: 'NUVOLA', category: 'Natura' },
      { word: 'FIUME', category: 'Natura' },
      { word: 'PIETRA', category: 'Natura' },
      { word: 'PANE', category: 'Cibo' },
      { word: 'LATTE', category: 'Cibo' },
      { word: 'CASA', category: 'Edifici' },
      { word: 'TORRE', category: 'Edifici' },
    ]);

    this._addPuzzles('it', 'medium', [
      { word: 'CAVALIERE', category: 'Storia' },
      { word: 'DRAGO', category: 'Mitologia' },
      { word: 'MAGO', category: 'Fantasia' },
      { word: 'CASTELLO', category: 'Edifici' },
      { word: 'TEMPIO', category: 'Edifici' },
      { word: 'GALASSIA', category: 'Spazio' },
      { word: 'RAZZO', category: 'Spazio' },
      { word: 'GIUNGLA', category: 'Natura' },
      { word: 'PONTE', category: 'Edifici' },
      { word: 'CHITARRA', category: 'Musica' },
      { word: 'AUTUNNO', category: 'Stagioni' },
      { word: 'GIARDINO', category: 'Natura' },
      { word: 'MERCATO', category: 'Luoghi' },
      { word: 'PALAZZO', category: 'Edifici' },
      { word: 'MUSEO', category: 'Cultura' },
    ]);

    this._addPuzzles('it', 'hard', [
      { word: 'BOSCO NERO', category: 'Natura' },
      { word: 'STELLA POLARE', category: 'Spazio' },
      { word: 'CHIARO LUNA', category: 'Natura' },
      { word: 'CORSA ORO', category: 'Storia' },
      { word: 'BALENA BLU', category: 'Animali' },
      { word: 'DRAGO ROSSO', category: 'Mitologia' },
      { word: 'FIOCCO NEVE', category: 'Natura' },
      { word: 'FORESTA PLUVIALE', category: 'Natura' },
      { word: 'BARRIERA CORALLO', category: 'Natura' },
      { word: 'CASTELLO SABBIA', category: 'Oggetti' },
    ]);

    // French puzzles
    this._addPuzzles('fr', 'easy', [
      { word: 'POMME', category: 'Fruits' },
      { word: 'POIRE', category: 'Fruits' },
      { word: 'CITRON', category: 'Fruits' },
      { word: 'CHAISE', category: 'Meubles' },
      { word: 'TABLE', category: 'Meubles' },
      { word: 'CHAT', category: 'Animaux' },
      { word: 'LION', category: 'Animaux' },
      { word: 'AIGLE', category: 'Animaux' },
      { word: 'NUAGE', category: 'Nature' },
      { word: 'FLEUVE', category: 'Nature' },
      { word: 'PIERRE', category: 'Nature' },
      { word: 'PAIN', category: 'Nourriture' },
      { word: 'LAIT', category: 'Nourriture' },
      { word: 'MAISON', category: 'Batiments' },
      { word: 'TOUR', category: 'Batiments' },
    ]);

    this._addPuzzles('fr', 'medium', [
      { word: 'CHEVALIER', category: 'Histoire' },
      { word: 'DRAGON', category: 'Mythologie' },
      { word: 'SORCIER', category: 'Fantaisie' },
      { word: 'CHATEAU', category: 'Batiments' },
      { word: 'TEMPLE', category: 'Batiments' },
      { word: 'GALAXIE', category: 'Espace' },
      { word: 'FUSEE', category: 'Espace' },
      { word: 'JUNGLE', category: 'Nature' },
      { word: 'PONT', category: 'Batiments' },
      { word: 'GUITARE', category: 'Musique' },
      { word: 'AUTOMNE', category: 'Saisons' },
      { word: 'JARDIN', category: 'Nature' },
      { word: 'MARCHE', category: 'Lieux' },
      { word: 'PALAIS', category: 'Batiments' },
      { word: 'MUSEE', category: 'Culture' },
    ]);

    this._addPuzzles('fr', 'hard', [
      { word: 'FORET NOIRE', category: 'Nature' },
      { word: 'ETOILE NORD', category: 'Espace' },
      { word: 'CLAIR LUNE', category: 'Nature' },
      { word: 'RUEE VERS OR', category: 'Histoire' },
      { word: 'BALEINE BLEUE', category: 'Animaux' },
      { word: 'DRAGON ROUGE', category: 'Mythologie' },
      { word: 'FLOCON NEIGE', category: 'Nature' },
      { word: 'FORET TROPICALE', category: 'Nature' },
      { word: 'RECIF CORAIL', category: 'Nature' },
      { word: 'CHATEAU SABLE', category: 'Objets' },
    ]);

    // Spanish puzzles
    this._addPuzzles('es', 'easy', [
      { word: 'MANZANA', category: 'Frutas' },
      { word: 'PERA', category: 'Frutas' },
      { word: 'LIMON', category: 'Frutas' },
      { word: 'SILLA', category: 'Muebles' },
      { word: 'MESA', category: 'Muebles' },
      { word: 'GATO', category: 'Animales' },
      { word: 'LEON', category: 'Animales' },
      { word: 'AGUILA', category: 'Animales' },
      { word: 'NUBE', category: 'Naturaleza' },
      { word: 'RIO', category: 'Naturaleza' },
      { word: 'PIEDRA', category: 'Naturaleza' },
      { word: 'PAN', category: 'Comida' },
      { word: 'LECHE', category: 'Comida' },
      { word: 'CASA', category: 'Edificios' },
      { word: 'TORRE', category: 'Edificios' },
    ]);

    this._addPuzzles('es', 'medium', [
      { word: 'CABALLERO', category: 'Historia' },
      { word: 'DRAGON', category: 'Mitologia' },
      { word: 'HECHICERO', category: 'Fantasia' },
      { word: 'CASTILLO', category: 'Edificios' },
      { word: 'TEMPLO', category: 'Edificios' },
      { word: 'GALAXIA', category: 'Espacio' },
      { word: 'COHETE', category: 'Espacio' },
      { word: 'SELVA', category: 'Naturaleza' },
      { word: 'PUENTE', category: 'Edificios' },
      { word: 'GUITARRA', category: 'Musica' },
      { word: 'OTONO', category: 'Estaciones' },
      { word: 'JARDIN', category: 'Naturaleza' },
      { word: 'MERCADO', category: 'Lugares' },
      { word: 'PALACIO', category: 'Edificios' },
      { word: 'MUSEO', category: 'Cultura' },
    ]);

    this._addPuzzles('es', 'hard', [
      { word: 'BOSQUE NEGRO', category: 'Naturaleza' },
      { word: 'ESTRELLA POLAR', category: 'Espacio' },
      { word: 'CLARO LUNA', category: 'Naturaleza' },
      { word: 'FIEBRE ORO', category: 'Historia' },
      { word: 'BALLENA AZUL', category: 'Animales' },
      { word: 'DRAGON ROJO', category: 'Mitologia' },
      { word: 'COPO NIEVE', category: 'Naturaleza' },
      { word: 'SELVA TROPICAL', category: 'Naturaleza' },
      { word: 'ARRECIFE CORAL', category: 'Naturaleza' },
      { word: 'CASTILLO ARENA', category: 'Objetos' },
    ]);
  }

  _addPuzzles(language, difficulty, puzzles) {
    if (!this.puzzles.has(language)) {
      this.puzzles.set(language, new Map());
    }
    const langMap = this.puzzles.get(language);
    if (!langMap.has(difficulty)) {
      langMap.set(difficulty, []);
    }

    const existing = langMap.get(difficulty);
    for (const p of puzzles) {
      existing.push({
        id: `${language}_${difficulty}_${existing.length}`,
        word: p.word,
        category: p.category,
        difficulty,
        language,
        hint: p.hint || '',
      });
    }
  }
}

module.exports = { PuzzleEngine };
