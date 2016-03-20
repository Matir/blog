---
layout: post
title: "DEF CON 22 CTF Quals: 3dttt"
date: 2014-05-21 14:07:02 +0000
permalink: /2014/05/21/def-con-22-ctf-quals-3dttt/
category: Security
tags: CTF,DEF CON CTF,Security
---
Unlike most of the challenges in DC22 quals, this one required no binary exploitation, no reversing, just writing a little code.  You needed to play 3-D Tic Tac Toe, and you needed to play fast.  Unfortunately, I didn't record the sessions, so I don't have the example output.

Basically, you just received an ASCII representation of each of the 3 boards making up the 3d-tic-tac-toe environment, and were prompted to provide x,y,z coordinates for your next move.  However, you had only a very short period of time (fractions of a second) to send your move, so playing by hand was impossible.  The winner of each board was the player with the most rows won, and it did go to the full 27 moves each time.  Also, it's important to note that the player always goes first, and that you have to win 50 rounds in order to receive the flag.

I chose this basic algorithm:

1. On the first move, play in the very center of the boards (1,1,1)
2. For each subsequent move, consider each available position.
    1. Consider each row that the position sits on.
    2. If the row has both X and O on it, award 0 -- the row is a lost cause.
    3. If playing would win that row for us, or block a win for our opponent (they have 2/3), award 3 points.
    4. If we already have something on that row, or they already have something on that row, award 1 point.  We're either making progress or blocking.
    5. Otherwise, no points.
3. Sum the row points for each position, and play in the highest scoring position.

I had no idea if this algorithm would work, but it was actually successful resulting in the flag on the first try.

    #!python
    import re
    import socket
    
    REMOTE = ('3dttt_87277cd86e7cc53d2671888c417f62aa.2014.shallweplayaga.me', 1234)
    
    class TTT(object):
    
      def __init__(self, host, port):
        self.s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.s.connect((host, port))
        self.state = [[[' ', ' ', ' '] for i in xrange(3)] for k in xrange(3)]
        self._buf = ''
        self._moves = 0
    
        self._read_intro()
        self._read_state()
        self._print_state()
    
      def _read_intro(self):
        buf = ''
        while 'Play well and play fast....' not in buf:
          buf += self.s.recv(1024)
        self._buf = buf.split('and play fast....')[1]
    
      def _read_state(self):
        buf = self._buf
        while True:
          if '\n' not in buf:
            buf += self.s.recv(2048)
          line, buf = buf.split('\n', 1)
          m = (re.match(' x.*z=([0-2])', line) or 
              re.match('Choose .* x.*z=([0-2])', line))
          if m:
            z = int(m.group(1))
            continue
          m = re.match('([0-2])  (.) \| (.) \| (.)', line)
          if m:
            y = int(m.group(1))
            for x in xrange(3):
              self.state[z][y][x] = m.group(x+2)
    
            if y == 2 and z == 2:
              break
    
        self._buf = buf
    
      def _send_move(self, x, y, z):
        self.s.send('%d,%d,%d\n' % (x,y,z))
    
      def _print_state(self):
        print '\nMove: %d' % self._moves
        for board in self.state:
          print '[[' + ']\n ['.join(','.join(c for c in r) for r in board) + ']]'
    
      @staticmethod
      def _score_row(*row):
        x = 0
        o = 0
        for p in row:
          x += 1 if p == 'X' else 0
          o += 1 if p == 'O' else 0
        if x+o == 3 or (x and o):
          # All 3 filled or lost cause, we're fucked
          return 0
        if x == 2 or o == 2:
          # Either blocking or winning a row
          return 3
        if x or o:
          return 1
        # Empty row
        return 0
    
      @staticmethod
      def _find_diagonals(x, y, z):
        """This is terrible, but works."""
        # Diagonals of 2 degrees of freedom
        if x == y:
          yield ((0, 0, z), (1, 1, z), (2, 2, z))
        if x+y == 2:
          yield ((0, 2, z), (1, 1, z), (2, 0, z))
        if x == z:
          yield ((0, y, 0), (1, y, 1), (2, y, 2))
        if x+z == 2:
          yield ((0, y, 2), (1, y, 1), (2, y, 0))
        if y == z:
          yield ((x, 0, 0), (x, 1, 1), (x, 2, 2))
        if y+z == 2:
          yield ((x, 0, 2), (x, 1, 1), (x, 2, 0))
        # Now the 4 big diagonals
        if x == y == z:
          yield ((0, 0, 0), (1, 1, 1), (2, 2, 2))
        for dia in [
            ((2, 0, 0), (1, 1, 1), (0, 2, 2)),
            ((2, 2, 0), (1, 1, 1), (0, 0, 2)),
            ((0, 2, 0), (1, 1, 1), (2, 0, 2))]:
          if (x, y, z) in dia:
            yield dia
    
      def _score_move(self, x, y, z):
        if self.state[z][y][x] != ' ':
          # Not a possible move
          return -1
        # Straight rows
        score = self._score_row(
            self.state[z][y][0],
            self.state[z][y][1],
            self.state[z][y][2])
        score += self._score_row(
            self.state[z][0][x],
            self.state[z][1][x],
            self.state[z][2][x])
        score += self._score_row(
            self.state[0][y][x],
            self.state[1][y][x],
            self.state[2][y][x])
        # Diagonals
        for d in self._find_diagonals(x, y, z):
          score += self._score_row(
              self.state[d[0][2]][d[0][1]][d[0][0]],
              self.state[d[1][2]][d[1][1]][d[1][0]],
              self.state[d[2][2]][d[2][1]][d[2][0]])
        return score
    
      def _optimal_move(self):
        # Initial move, go for center
        if self._moves == 0:
          return (1, 1, 1)
        # Score each position
        bestpos = None
        max_score = -1
        for x in xrange(3):
          for y in xrange(3):
            for z in xrange(3):
              score = self._score_move(x, y, z)
              if score > max_score:
                max_score = score
                bestpos = (x, y, z)
        print bestpos, 'score:', max_score
        return bestpos
    
      def move(self):
        where = self._optimal_move()
        if where is None:
          m = re.search('You\'ve won [0-9]+ rounds', self._buf)
          if m:
            print m.group(0)
          self._moves = 0
        else:
          self._send_move(*where)
          self._moves += 1
        self._read_state()
        self._print_state()
        return True
    
    
    if __name__ == '__main__':
      ttt = TTT(REMOTE[0], REMOTE[1])
      while ttt.move():
        continue
      print ttt._buf
      print ttt.s.recv(1024)

