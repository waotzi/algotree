const Graphics = PIXI.Graphics;

const branch = {
    deg: 0,
    x1: 0,
    y1: 0,
    x2: 0,
    y2: 0,
    w: 0,
    h: 0,
    color: [0, 0, 0, 0],
    line: null,
}
const leaf = {
    row: 0,
    x1: 0,
    y1: 0,
    x2: 0,
    y2: 0,
    r: 0,
    color: [0, 0, 0, 0],
    circle: null,
};

const deg_to_rad = Math.PI / 180.0;
function randomIntFromInterval(min, max) { // min and max included 
    return Math.floor(Math.random() * (max - min + 1) + min)
  }
  
function get_rot_x(deg) {
    return Math.cos(deg * deg_to_rad);
}
function get_rot_y(deg) {
    return Math.sin(deg * deg_to_rad);
}
function get_color(cs) {
    const r = randomIntFromInterval(cs[0], cs[1]);
    const g = randomIntFromInterval(cs[2], cs[3]);
    const b = randomIntFromInterval(cs[4], cs[5]);
    return '0x' + to_hex(r) + to_hex(g) + to_hex(b)
}
function to_hex(i) {
    return i.toString(16).toUpperCase();
}

const tree = {
    branches : Array(0).fill([]),
    leaves : [],
    leaf_chance : 0.5,
    max_row : 10,
    current_row : 0,
    x : 300,
    y : 400,
    w : 10,
    h : 40,
    random_row : false,
    split_chance : 50,
    split_angle : [20, 30],
    cs_branch : [125, 178, 122, 160, 76, 90],
    cs_leaf : [150, 204, 190, 230, 159, 178],
    left_x : 9999999,
    right_x : -9999999,
    grow_timer : 0,
    grow_time : 20,
    load : function() {
        this.branches = Array(this.max_row + 1);
        for (var i = 0; i < this.branches.length; i++) {
            this.branches[i] = []
        }

        var b = Object.create(branch);
        b.deg = -90;
        [b.x1, b.y1] = [this.x, this.y];
        [b.x2, b.y2] = [this.x, this.y];
        [b.w, b.h] = [this.w, this.h];
        b.color = get_color(this.cs_branch);
        this.branches[0].push(b);
        this.grow_timer = randomIntFromInterval(0, this.grow_time);
        if (this.random_row) {
            var grow_to_row = randomIntFromInterval(this.max_row);
            while (this.current_row < grow_to_row) {
                this.grow();
            }
        }
    },
    add_branch : function(deg, b) {
        var nb = Object.create(branch);
        nb.w = b.w * 0.9;
        nb.h = b.h * 0.95;
        nb.deg = deg;
        [nb.x1, nb.y1] = [b.x2, b.y2];
        nb.x2 = nb.x1 + get_rot_x(deg) * nb.h;
        nb.y2 = nb.y1 + get_rot_y(deg) * nb.h;
        nb.color = get_color(this.cs_branch);
        this.branches[this.current_row + 1].push(nb);
        const line = new Graphics();
        app.stage.addChild(line);
        nb.line = line;
    

        var leaf_chance = Math.random() * (this.current_row / this.max_row);
        if (leaf_chance > this.leaf_chance) {
            var div_x = get_rot_x(deg * 2) * nb.w;
            var div_y = get_rot_y(deg * 2) * nb.w;
            var nl = Object.create(leaf);
            nl.row = this.current_row;
            nl.r = nb.w;
            [nl.x1, nl.y1] = [nb.x2 + div_x, nb.y2 + div_y];
            [nl.x2, nl.y2] = [nb.x2 - div_x, nb.y2 - div_y];
            nl.color = get_color(this.cs_leaf);
            this.leaves.push(nl);
            const circ = new Graphics();
            app.stage.addChild(circ);
            nl.circle = circ;
        }
        if (nb.x2 < this.left_x) {
            this.left_x = nb.x2;
        } else if (nb.x2 > this.right_x) {
            this.right_x = nb.x2 + nb.w;
        }   
    },
    get_angle: function() {
        return randomIntFromInterval(this.split_angle[0], this.split_angle[1]);
    },
    grow : function() {
        var prev_row = this.branches[this.current_row];
        for (var i = 0; i < prev_row.length; i++) {
            const b = prev_row[i];
        
            var split = randomIntFromInterval(0, 100);
            if (this.split_chance > split) {
                this.add_branch(b.deg - this.get_angle(), b);
                this.add_branch(b.deg + this.get_angle(), b);

            } else {
                this.add_branch(b.deg, b);
            }
        }
        this.current_row += 1;
        
    },
    update: function() {
        if (this.grow_timer > 0) {
            this.grow_timer -= 1;
        }
        if (this.grow_timer == 0 && this.current_row < this.max_row ) {

            this.grow();
            this.grow_timer = this.grow_time;
        } 
    },
    get_next_pos: function(a, b) {
        return b + (a - b) * this.grow_timer / this.grow_time; 
    },
    draw() {
        var row = this.branches[this.current_row];
        for (j in row) {
            var b = row[j];
            var line = b.line;
            if (line) {
                line.clear()
                var [x2, y2] = [b.x2, b.y2];
                if (this.grow_timer > 1) {
                    x2 = this.get_next_pos(b.x1, x2);
                    y2 = this.get_next_pos(b.y1, y2);
                }
                line.lineStyle({width: b.w, color: b.color, alpha: 1});
                line.beginFill(b.color);
                    
                line.moveTo(b.x1, b.y1);
                line.lineTo(x2, y2);
                line.endFill();
            }
                
        }
        for (j in this.leaves) {
            var l = this.leaves[j];
            if (l.row == this.current_row - 1 && this.grow_timer < 2) {
                var circ = l.circle;
                if (circ) {
                    circ.lineStyle({width: l.w, color: l.color, alpha: 1});
                    circ.beginFill(l.color);
                    circ.drawCircle(l.x1, l.y1, l.r);
                    circ.drawCircle(l.x2, l.y2, l.r);
                    circ.endFill();
                }
            }
        }
        
    
    }
  };