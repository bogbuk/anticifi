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
  CreatedAt,
  UpdatedAt,
  DeletedAt,
} from 'sequelize-typescript';

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

  @Default(false)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare isEmailVerified: boolean;

  @AllowNull(true)
  @Column(DataType.DATE)
  declare lastLoginAt: Date | null;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @DeletedAt
  declare deletedAt: Date | null;
}
