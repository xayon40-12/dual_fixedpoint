# Dual fixedpoint

Test of fixed-point acceleration with dual numbers.  

## Goal

The goal of this demo is to showcase the greater convergence of using dual number as a way to do a kind of line-search along the directions followed by a fixed-point iteration. The current demo show the complex plane where the origin is in the center, and the green point corresponds to the square root of the red point, which is itself controlled by the position of the cursor. The origin is represented by the white circle. The Blue curve corresponds to using a single dual which correspond to first order derivative, whereas the purple curve corresponds to using dual of dual which can access second order derivatives.

## Usage

This is a graphics demonstrator made in lua with [LOVE2D](https://love2d.org). To execute this program, you need [LOVE2D](https://love2d.org) to be installed. You can download it from their website or on MacOS
```sh
brew install love
```
Then you can execute from the root of this directory
```sh
love .
```
