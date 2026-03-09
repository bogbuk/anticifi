import {
  Table,
  Column,
  Model,
  DataType,
  PrimaryKey,
  Default,
  Unique,
  AllowNull,
  HasMany,
  HasOne,
  CreatedAt,
  UpdatedAt,
  DeletedAt,
} from 'sequelize-typescript';
import { Subscription } from '../subscriptions/subscription.model.js';

export enum UserRole {
  USER = 'USER',
  ADMIN = 'ADMIN',
}

export enum UserTheme {
  DARK = 'dark',
  LIGHT = 'light',
  SYSTEM = 'system',
}

@Table({
  tableName: 'users',
  timestamps: true,
  paranoid: true,
  underscored: true,
})
export class User extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @Unique
  @AllowNull(false)
  @Column(DataType.STRING(255))
  declare email: string;

  @AllowNull(false)
  @Column({ type: DataType.STRING(255), field: 'password_hash' })
  declare passwordHash: string;

  @AllowNull(true)
  @Column(DataType.STRING(100))
  declare firstName: string | null;

  @AllowNull(true)
  @Column(DataType.STRING(100))
  declare lastName: string | null;

  @AllowNull(true)
  @Column(DataType.STRING(500))
  declare avatarUrl: string | null;

  @Default('USD')
  @AllowNull(false)
  @Column(DataType.STRING(3))
  declare currency: string;

  @Default('en')
  @AllowNull(false)
  @Column(DataType.STRING(10))
  declare locale: string;

  @Default(true)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare notificationsEnabled: boolean;

  @Default(UserTheme.SYSTEM)
  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(UserTheme)))
  declare theme: UserTheme;

  @Default(UserRole.USER)
  @AllowNull(false)
  @Column(DataType.ENUM(...Object.values(UserRole)))
  declare role: UserRole;

  @Default(false)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare isEmailVerified: boolean;

  @AllowNull(true)
  @Column(DataType.STRING(500))
  declare fcmToken: string | null;

  @Default(false)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare onboardingCompleted: boolean;

  @AllowNull(true)
  @Column(DataType.DATE)
  declare lastLoginAt: Date | null;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @DeletedAt
  declare deletedAt: Date | null;

  @HasOne(() => Subscription)
  declare subscription: Subscription;
}
