Dual = {}

function Dual:new(a, b)
	return setmetatable({ a = a, b = b }, {
		__index = Dual,
		__add = function(l, r)
			return Dual:new(l.a + r.a, l.b + r.b)
		end,
		__sub = function(l, r)
			return Dual:new(l.a - r.a, l.b - r.b)
		end,
		__mul = function(l, r)
			return Dual:new(l.a * r.a, l.a * r.b + r.a * l.b)
		end,
		__div = function(l, r)
			local x = l.a / r.a
			return Dual:new(x, (l.b - r.b * l.b * x) / r.a)
		end,
	})
end

function Dual:one()
	if type(self.a) == "table" then
		return Dual:new(self.a:one(), self.b:zero())
	else
		return Dual:new(1, 0)
	end
end

function Dual:zero()
	if type(self.a) == "table" then
		return Dual:new(self.a:zero(), self.b:zero())
	else
		return Dual:new(0, 0)
	end
end

Complex = {}

function Complex:new(a, b)
	return setmetatable({ a = a, b = b }, {
		__index = Complex,
		__add = function(l, r)
			return Complex:new(l.a + r.a, l.b + r.b)
		end,
		__sub = function(l, r)
			return Complex:new(l.a - r.a, l.b - r.b)
		end,
		__mul = function(l, r)
			return Complex:new(l.a * r.a - l.b * r.b, l.a * r.b + r.a * l.b)
		end,
		__div = function(l, r)
			local n = r:abs()
			return Complex:new((l.a * r.a + l.b * r.b) / n, (l.b * r.a - l.a * r.b) / n)
		end,
	})
end

function Complex:one()
	if type(self.a) == "table" then
		return Complex:new(self.a:one(), self.b:zero())
	else
		return Complex:new(1, 0)
	end
end

function Complex:zero()
	if type(self.a) == "table" then
		return Complex:new(self.a:zero(), self.b:zero())
	else
		return Complex:new(0, 0)
	end
end

function Complex:abs()
	return self.a * self.a + self.b * self.b
end

function Complex:conj()
	return Complex:new(self.a, -self.b)
end

function Complex:recip()
	local n = self:abs()
	return Complex:new(self.a / n, -self.b / n)
end

function Complex:sqrt()
	local n = math.sqrt(math.sqrt(self:abs()))
	local t = math.atan2(self.b, self.a) * 0.5
	return Complex:new(n * math.cos(t), n * math.sin(t))
end

function Complex:normalized()
	local n = math.sqrt(self:abs())
	return Complex:new(self.a / n, self.b / n)
end

function Complex.zip(l, r, f)
	return Complex:new(f(l.a, r.a), f(l.b, r.b))
end

function Complex:map(f)
	return Complex:new(f(self.a), f(self.b))
end

function Complex:recip_zero()
	return function(z0, z)
		return z * z0 - z0:one()
	end
end

function Complex:sqrt_zero()
	return function(z0, z)
		return z * z - z0
	end
end

function hsl(h, s, l)
	h = h / 360
	s = s / 100
	l = l / 100

	local r, g, b

	if s == 0 then
		r, g, b = l, l, l -- achromatic
	else
		local function hue2rgb(p, q, t)
			if t < 0 then
				t = t + 1
			end
			if t > 1 then
				t = t - 1
			end
			if t < 1 / 6 then
				return p + (q - p) * 6 * t
			end
			if t < 1 / 2 then
				return q
			end
			if t < 2 / 3 then
				return p + (q - p) * (2 / 3 - t) * 6
			end
			return p
		end

		local q = l < 0.5 and l * (1 + s) or l + s - l * s
		local p = 2 * l - q
		r = hue2rgb(p, q, h + 1 / 3)
		g = hue2rgb(p, q, h)
		b = hue2rgb(p, q, h - 1 / 3)
	end

	local a = 1
	return function()
		return r, g, b, a
	end
end

function love.load()
	S = {}
	S.cz = Complex:new(0, 0)
	S.r = 10
	S.s = 2
	S.col = { hsl(0, 90, 70), hsl(100, 90, 70) }
	local a = 60
	S.col_0 = hsl(a, 90, 70)
	S.col_1 = hsl(a + 120, 90, 70)
	S.col_2 = hsl(a + 240, 90, 70)
end

function love.update(dt) end

function love.draw()
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	local tx = function(x)
		return (x / (2 * S.s) + 0.5) * w
	end
	local ty = function(y)
		return (y / (2 * S.s * h / w) + 0.5) * h
	end

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.circle("fill", tx(0), ty(0), S.r, 5)
	for i, z in ipairs({ S.cz, S.cz:sqrt() }) do
		love.graphics.setColor(S.col[i]())
		love.graphics.circle("fill", tx(z.a), ty(z.b), S.r, 10)
	end

	local eps = 0.01
	local f = Complex:sqrt_zero()
	local z0 = S.cz
	local start = Complex:new(1, 0)
	local zp = start
	local d = f(z0, zp)
	local z
	love.graphics.setColor(S.col_0())
	local m0 = 0
	for i = 1, 100 do
		d = f(z0, zp)
		z = zp + d
		love.graphics.line(tx(zp.a), ty(zp.b), tx(z.a), ty(z.b))
		zp = z
		if d:abs() < eps then
			m0 = i
			break
		end
	end
	love.graphics.print("Order 0: " .. tostring(m0), 10, 10)

	zp = start
	d = f(z0, zp)
	love.graphics.setColor(S.col_1())
	local m1 = 0
	for i = 1, 100 do
		local dz = f(
			z0:map(function(x)
				return Dual:new(x, 0)
			end),
			zp:zip(d, function(x, y)
				return Dual:new(x, y)
			end)
		)
		local nr = Complex:new(dz.a.a, dz.b.a)
		local ne = Complex:new(dz.a.b, dz.b.b)
		z = zp - d * Complex:new((nr.a * ne.a + nr.b * ne.b) / (ne.a * ne.a + ne.b * ne.b), 0)
		love.graphics.line(tx(zp.a), ty(zp.b), tx(z.a), ty(z.b))
		zp = z
		d = Complex:new(d.b, -d.a) -- Note: take a direction orthogonal to the current one
		if nr:abs() < eps * eps then
			m1 = i
			break
		end
	end
	love.graphics.print("Order 1: " .. tostring(m1), 10, 20)

	zp = start
	d = f(z0, zp)
	love.graphics.setColor(S.col_2())
	local m2 = 0
	for i = 1, 100 do
		local dz = f(
			z0:map(function(x)
				return Dual:new(Dual:new(x, 0), Dual:new(0, 0))
			end),
			zp:zip(d, function(x, y)
				return Dual:new(Dual:new(x, y), Dual:new(y, 0))
			end)
		)
		local nr = Complex:new(dz.a.a.a, dz.b.a.a)
		local ne = Complex:new(dz.a.a.b, dz.b.a.b)
		local nee = Complex:new(dz.a.b.b, dz.b.b.b)
		local acce = nr.a * nee.a + nr.b * nee.b
		z = zp - d * Complex:new((nr.a * ne.a + nr.b * ne.b) / (ne.a * ne.a + ne.b * ne.b + math.max(0, acce)), 0)
		love.graphics.line(tx(zp.a), ty(zp.b), tx(z.a), ty(z.b))
		zp = z
		d = Complex:new(d.b, -d.a)
		if nr:abs() < eps * eps then
			m2 = i
			break
		end
	end
	love.graphics.print("Order 2: " .. tostring(m2), 10, 30)
end

function love.mousemoved(x, y, dx, dy, istouch)
	local w = love.graphics.getWidth()
	local h = love.graphics.getHeight()
	S.cz.a = (x / w - 0.5) * 2 * S.s
	S.cz.b = (y / h - 0.5) * 2 * S.s * h / w
end
