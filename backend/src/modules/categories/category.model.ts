import {
  Table,
  Column,
  Model,
  DataType,
  PrimaryKey,
  Default,
  AllowNull,
  ForeignKey,
  BelongsTo,
  HasMany,
  CreatedAt,
  UpdatedAt,
  DeletedAt,
} from 'sequelize-typescript';
import { User } from '../users/user.model.js';

@Table({
  tableName: 'categories',
  timestamps: true,
  paranoid: true,
  underscored: true,
})
export class Category extends Model {
  @PrimaryKey
  @Default(DataType.UUIDV4)
  @Column(DataType.UUID)
  declare id: string;

  @AllowNull(false)
  @Column(DataType.STRING(100))
  declare name: string;

  @AllowNull(true)
  @Column(DataType.STRING(50))
  declare icon: string | null;

  @AllowNull(true)
  @Column(DataType.STRING(20))
  declare color: string | null;

  @Default(false)
  @AllowNull(false)
  @Column(DataType.BOOLEAN)
  declare isDefault: boolean;

  @ForeignKey(() => User)
  @AllowNull(true)
  @Column(DataType.UUID)
  declare userId: string | null;

  @ForeignKey(() => Category)
  @AllowNull(true)
  @Column(DataType.UUID)
  declare parentId: string | null;

  @CreatedAt
  declare createdAt: Date;

  @UpdatedAt
  declare updatedAt: Date;

  @DeletedAt
  declare deletedAt: Date | null;

  @BelongsTo(() => User)
  declare user: User;

  @BelongsTo(() => Category, 'parentId')
  declare parent: Category;

  @HasMany(() => Category, 'parentId')
  declare children: Category[];
}
