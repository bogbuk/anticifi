import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { InjectModel } from '@nestjs/sequelize';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { User } from '../../users/user.model.js';

interface JwtPayload {
  userId: string;
  email: string;
  role: string;
  iat: number;
  exp: number;
}

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    configService: ConfigService,
    @InjectModel(User) private readonly userModel: typeof User,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET', 'default-secret-change-me'),
    });
  }

  async validate(payload: JwtPayload): Promise<{ id: string; userId: string; email: string; role: string }> {
    const user = await this.userModel.findByPk(payload.userId, {
      attributes: ['id', 'email', 'role'],
    });

    if (!user) {
      return { id: payload.userId, userId: payload.userId, email: payload.email, role: 'USER' };
    }

    return { id: user.id, userId: user.id, email: user.email, role: user.role };
  }
}
