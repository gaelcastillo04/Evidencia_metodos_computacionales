class CPU:
    def __init__(self, filename):
        self.filename = filename
        self.grid_size = 10
        self.field = [['.' for _ in range(self.grid_size)] for _ in range(self.grid_size)]
        self.x = self.y = self.grid_size // 2
        self.angle = 0  # 0=arriba, 90=derecha, 180=abajo, 270=izquierda

    def load_instructions(self):
        with open(self.filename, 'r') as f:
            self.instructions = [line.strip().split(',') for line in f if line.strip()]

    def execute(self):
        self.field[self.x][self.y] = 'S'  # Marca inicio
        for idx, (instr, val) in enumerate(self.instructions):
            instr = instr.lower()  # Acepta mayúsculas
            print(f"Executing instruction {idx + 1}: {instr},{val}")
            if instr == 'mov':
                self.move(int(val))
            elif instr == 'turn':
                self.turn(int(val))
            self.draw_field()
        self.field[self.x][self.y] = 'E'  # Marca fin
        self.draw_field()
        print(f"Final direction: {self.get_direction_symbol()}")

    def turn(self, angle):
        self.angle = (self.angle + angle) % 360

    def get_direction(self):
        if self.angle == 0:
            return -1, 0
        elif self.angle == 90:
            return 0, 1
        elif self.angle == 180:
            return 1, 0
        elif self.angle == 270:
            return 0, -1
        else:
            raise ValueError(f"Invalid angle: {self.angle}")

    def get_direction_symbol(self):
        if self.angle == 0:
            return '↑'
        elif self.angle == 90:
            return '→'
        elif self.angle == 180:
            return '↓'
        elif self.angle == 270:
            return '←'
        else:
            return '?'

    def move(self, steps):
        dx, dy = self.get_direction()
        for _ in range(steps):
            next_x = self.x + dx
            next_y = self.y + dy
            if not (0 <= next_x < self.grid_size and 0 <= next_y < self.grid_size):
                print("ERROR: USER MOVE PASSED THE BOUNDARIES OF THE MATRIX")
                exit(1)
            self.x = next_x
            self.y = next_y
            if self.field[self.x][self.y] == '.':
                self.field[self.x][self.y] = '*'

    def draw_field(self):
        for i, row in enumerate(self.field):
            line = ''
            for j, cell in enumerate(row):
                if i == self.x and j == self.y:
                    line += self.get_direction_symbol()
                else:
                    line += cell
            print(line)
        print('-' * self.grid_size)

if __name__== "__main__":
    cpu = CPU("instructions.asm")
    cpu.load_instructions()
    cpu.execute()